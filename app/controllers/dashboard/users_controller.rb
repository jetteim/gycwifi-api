module Dashboard
  # Users controller
  class UsersController < ApplicationController
    PAGESIZE = 20
    before_action :parse_params
    skip_before_action :authenticate_user, only: [:request_password]

    def index
      return raise_not_authorized(User) unless RedisCache.cached_policy(@current_user, User, 'index')
      users = policy_scope(User)
      items_count = users.count
      render json: {
        data: {
          itemsOnPage: PAGESIZE,
          users: users.page(@page).per(PAGESIZE),
          items_count: items_count,
          can_create: RedisCache.cached_policy(@current_user, User, 'create')
        },
        status: 'ok',
        message: 'Social accounts'
      }
    end

    def create
      return raise_not_authorized(User) unless RedisCache.cached_policy(@current_user, User, 'create')
      user = User.new(user_params)
      user.user_id = current_user.id
      if user.save
        render json: {
          data: { user: user },
          status: 'ok',
          message: 'ok'
        }
      else
        render json: {
          data: nil,
          status: 'error',
          message: I18n.t('errors.no_access')
        }
      end
    end

    def show
      authorize(@object_user)
      render json: {
        data: {
          user: @object_user,
          users: policy_scope(User),
          brands: policy_scope(Brand),
          locations: policy_scope(Location),
          routers: policy_scope(Router),
          opinions: policy_scope(Opinion),
          polls: policy_scope(Poll)
        },
        status: 'ok',
        message: 'user and available objects'
      }
    end

    def update
      authorize(@object_user)
      if @object_user.update(user_params)
        render json: @object_user.front_model
      else
        render json: { error: user.errors.full_messages }
      end
    end

    def destroy
      authorize @brand
      if @brand.destroy
        render json: {
          data: nil,
          status: 'ok',
          message: I18n.t('errors.brands.deleted')
        }
      else
        render json: {
          data: nil,
          status: 'error',
          message: I18n.t('errors.no_access')
        }
      end
    end

    def request_password
      user = User.find_by(email: @str_prms[:email])
      if user
        user.update(password: SecureRandom.hex(3))
        RequestPasswordMailer.request_password(user.email, user.password).deliver_later
        render json: {
          message: 'User password recovery sent to your e-mail address',
          status: 200
        }, status: 200
      else
        render json: {
          error: 'User not found',
          status: 200
        }, status: 200
      end
    end

    def lang
      user = User.find_by(id: @current_user.id)
      user.update(lang: @str_prms[:lang])
      if user.save
        render json:
        { data: nil, message: 'User language updated', status: 'ok' }
      else
        render json: { data: nil, message: 'Error', status: 'error' }
      end
    end

    def accounts
      authorize User
      users = policy_scope(User)
      # build account info and locations detains for each user
      render json: @accounts ||= {
        items_count: users.count,
        itemsOnPage: PAGESIZE,
        can_create: policy(User).create?,
        accounts: users.page(@page).per(PAGESIZE).as_json(include: :locations)
      }
    end

    def users
      authorize User
      users = policy_scope(User)
      # build account info and locations detains for each user
      render json: {
        items_count: users.count,
        can_create: policy(User).create?,
        itemsOnPage: PAGESIZE,
        users: users.page(@page).per(PAGESIZE).as_json
      }
    end

    def routers
      authorize User
      routers = policy_scope(Router)
      # build account info and locations detains for each user
      render json: {
        items_count: routers.count,
        itemsOnPage: PAGESIZE,
        can_create: policy(Router).create?,
        users: routers.page(@page).per(PAGESIZE).as_json
      }
    end

    def locations
      authorize User
      locations = policy_scope(Location)
      # build account info and locations detains for each user
      render json: {
        items_count: locations.count,
        itemsOnPage: PAGESIZE,
        can_create: policy(Location).create?,
        locations: locations.page(@page).per(PAGESIZE).as_json
      }
    end

    def brands
      authorize User
      brands = policy_scope(Brand)
      # build account info and locations detains for each user
      render json: {
        items_count: brands.count,
        itemsOnPage: PAGESIZE,
        can_create: policy(Brand).create?,
        brands: brands.page(@page).per(PAGESIZE).as_json
      }
    end

    private

    def parse_params
      @page = @str_prms[:page].to_i || 1
      @object_user = @str_prms[:id] ? User.find(@str_prms[:id]) : nil
    end

    def avatar_params
      params.permit(:password, :avatar, :role_cd, :tour, :email)
    end

    def user_params
      params.require(:user).permit(:password, :avatar, :type, :tour, :email, :user)
    end
  end
end
