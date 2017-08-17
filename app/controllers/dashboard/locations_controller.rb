class Dashboard::LocationsController < ApplicationController
  include Skylight::Helpers
  before_action :current_location, only: %i[show update destroy]
  before_action :parse_params
  PAGESIZE = 20

  instrument_method
  def index
    return raise_not_authorized(Location) unless RedisCache.cached_policy(@current_user, Location, 'index')
    locations = @str_prms[:brand_id] ? policy_scope(Location).brand_locations(@str_prms[:brand_id].to_i) : policy_scope(Location)
    items_count = locations.pluck(:id).count
    locations = locations.order(:id).page(@page).per(@itemsOnPage)
    render json: {
      data: {
        itemsOnPage: @itemsOnPage,
        locations: locations.as_json(only: %i[id title slug address logo promo_text]),
        items_count: items_count,
        can_create: RedisCache.cached_policy(@current_user, Location, 'create')
      },
      status: 'ok',
      message: 'Locations list'
    }
  end

  instrument_method
  def show
    return raise_not_authorized(@location) unless RedisCache.cached_policy(@current_user, @location, 'show')
    render json: {
      data: { location: @location.as_json },
      status: 'ok',
      message: 'Location by ID'
    }
  end

  instrument_method
  def create
    return raise_not_authorized(Location) unless RedisCache.cached_policy(@current_user, Location, 'create')
    location = Location.new(location_params)
    location.user_id ||= @current_user.id
    location.slug = nil
    location.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.locations.#{k}") } } unless location.save
    render json: success(location, 'created')
  end

  def update
    return raise_not_authorized(@location) unless RedisCache.cached_policy(@current_user, @location, 'update')
    RedisCache.flush('location', @location.id)
    @location.slug = nil
    @location.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.locations.#{k}") } } unless @location.update(location_params)
    render json: success(@location, 'created')
  end

  def destroy
    return raise_not_authorized(@location) unless RedisCache.cached_policy(@current_user, @location, 'destroy')
    RedisCache.flush('location', @location.id)
    @location.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.locations.#{k}") } } unless @location.destroy
    render json: success(@location, 'deleted')
  end

  private

  def success(location, action)
    {
      data: {
        location: location
      },
      status: 'ok',
      message: I18n.t("errors.locations.#{action}")
    }
  end

  def parse_params
    @page = @str_prms[:page].to_i || 1
    @page = 1 if @page < 1
    @itemsOnPage = @str_prms[:itemsOnPage] || PAGESIZE
  end

  def current_location
    @location = Location.friendly.find(@str_prms[:id])
  end

  def location_params
    params.require(:location).permit(
      :title, :phone, :address, :extended_address, :url, :ssid, :staff_ssid, :staff_ssid_pass,
      :sms_auth, :redirect_url, :wlan, :wan, :auth_expiration_time, :promo_text,
      :logo, :bg_color, :background, :password, :twitter, :google,
      :vk, :insta, :facebook, :brand_id, :category_id, :user_id, :voucher, :poll_id,
      :last_page_content, :view_brand, :slug
    )
  end
end
