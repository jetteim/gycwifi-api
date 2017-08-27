class Dashboard::RoutersController < ApplicationController
  before_action :current_router, only: %i[show update destroy config package]
  before_action :parse_params
  # include Skylight::Helpers
  # before_action :check_access_rights
  PAGESIZE = 20

  # instrument_method
  def index
    return raise_not_authorized(Router) unless RedisCache.cached_policy(@current_user, Router, 'index')
    routers = policy_scope(Router).order(:id)
    routers = routers.where(location_id: @str_prms[:location_id]) if @str_prms[:location_id]
    render json: {
      data: {
        itemsOnPage: @itemsOnPage,
        routers: routers.page(@page).per(@itemsOnPage).as_json,
        items_count: routers.pluck(:id).count,
        can_create: RedisCache.cached_policy(@current_user, Router, 'create')
      }
    }
  end

  # instrument_method
  def show
    return raise_not_authorized(@router) unless RedisCache.cached_policy(@current_user, @router, 'show')
    render json: {
      data: { router: @router },
      status: 'ok',
      message: 'Router by ID'
    }
  end

  def package
    return raise_not_authorized(@router) unless RedisCache.cached_policy(@current_user, @router, 'show')
    send_file(@router.package)
  end

  # instrument_method
  def create
    return raise_not_authorized(Router) unless RedisCache.cached_policy(@current_user, Router, 'create')
    router = Router.new(router_params)
    router.user_id = @current_user.id
    if router.save
      render json: {
        data: { router: router },
        status: 'ok',
        message: I18n.t('errors.routers.created')
      }
    else
      render json: {
        data: nil,
        status: 'error',
        message: I18n.t('errors.no_access')
      }
    end
  end

  # instrument_method
  def update
    return raise_not_authorized(@router) unless RedisCache.cached_policy(@current_user, @router, 'update')
    RedisCache.flush('router', @router.id)
    if @router.update router_params
      render json: { data: { router: @router }, status: 'ok', message: I18n.t('errors.routers.updated') }
    else
      render json: { data: nil, status: 'error', message: I18n.t('errors.no_access') }
    end
  end

  # instrument_method
  def destroy
    return raise_not_authorized(@router) unless RedisCache.cached_policy(@current_user, @router, 'destroy')
    RedisCache.flush('router', @router.id)
    if @router.destroy
      render json: {
        data: nil,
        status: 'ok',
        message: I18n.t('errors.routers.deleted')
      }
    else
      render json: {
        data: nil,
        status: 'error',
        message: I18n.t('errors.no_access')
      }
    end
  end

  # def config
  #   authorize(@router, :show?)
  #   data = []
  #   # data << {
  #   #   format: 'ssh',
  #   #   command: ''
  #   # }
  #   # data << {
  #   #   format: 'snmp',
  #   #   oid: '',
  #   #   value: ''
  #   # }
  #   render json: {
  #     data: { config: data },
  #     status: 'ok',
  #     message: 'Router by ID'
  #   }
  # end
  #
  private

  # instrument_method
  def current_router
    @router = Router.find(@str_prms[:id])
  end

  # instrument_method
  def parse_params
    @page = @str_prms[:page].to_i || 1
    @page = 1 if @page < 1
    @itemsOnPage = @str_prms[:itemsOnPage] || PAGESIZE
  end

  def router_params
    params.require(:router).permit(:serial, :comment, :location_id)
  end

  # def router_params
  #   params.require(:router).permit(
  #     :id, :serial, :comment, :location_id, :first_dns_server, :second_dns_server,
  #     :common_name, :ip_name, :router_local_ip, :disable_service_access,
  #     :split_networks, :isolate_wlan, :block_service_ports,
  #     :admin_ethernet_port, :router_admin_ip, :radius_secret, :admin_password,
  #     :ssl_certificate, :ssl_key, :radius_db_nas_id, :status
  #   )
  # end

  # def check_access_rights
  #   render json: { error: 'No access', status: 403 } unless user_has_access?
  # end
end
