class Dashboard::BrandsController < ApplicationController
  PAGESIZE = 20

  include Skylight::Helpers
  before_action :get_brand, only: %i[show update destroy]

  def index
    return raise_not_authorized(Brand) unless RedisCache.cached_policy(@current_user, Brand, 'index')
    brands = policy_scope(Brand)
    items_count = brands.pluck(:id).count
    render json: {
      data: {
        itemsOnPage: PAGESIZE,
        brands: brands.order(:id).page(@str_prms[:page]).as_json,
        items_count: items_count,
        can_create: RedisCache.cached_policy(current_user, Brand, 'create')
      },
      status: 'ok',
      message: 'Brands list'
    }
  end

  def show
    return raise_not_authorized(@brand) unless RedisCache.cached_policy(current_user, @brand, 'show')
    render json: {
      data: { brand: @brand.as_json },
      status: 'ok',
      message: 'Brand by ID'
    }
  end

  def create
    return raise_not_authorized(Brand) unless RedisCache.cached_policy(@current_user, Brand, 'create')
    brand = Brand.new(brand_params)
    brand.user_id ||= @current_user.id
    brand.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.brands.#{k}") } } unless brand.save
    render json: success(brand, 'created')
  end

  def update
    return raise_not_authorized(@brand) unless RedisCache.cached_policy(@current_user, @brand, 'update')
    RedisCache.flush('brand', @brand.id)
    @brand.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.brands.#{k}") } } unless @brand.update(brand_params)
    render json: success(@brand, 'updated')
  end

  def destroy
    return raise_not_authorized(@brand) unless RedisCache.cached_policy(@current_user, @brand, 'destroy')
    RedisCache.flush('brand', @brand.id)
    @brand.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.brands.#{k}") } } unless @brand.destroy
    render json: success(@brand, 'deleted')
  end

  private

  def success(brand, action)
    {
      data: { brand: brand },
      status: 'ok',
      message: I18n.t("errors.brands.#{action}")
    }
  end

  def get_brand
    @brand = Brand.friendly.find(@str_prms[:id])
  end

  def brand_params
    params.require(:brand).permit(
      :title, :bg_color, :background, :logo, :sms_auth, :redirect_url,
      :auth_expiration_time, :category_id, :promo_text, :layout_id,
      :public, :user_id, :template
    )
  end
end
