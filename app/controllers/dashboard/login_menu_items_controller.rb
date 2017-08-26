class Dashboard::LoginMenuItemsController < ApplicationController
  # include Skylight::Helpers
  before_action :current_login_menu_item, only: %i[show update destroy]
  before_action :parse_params
  PAGESIZE = 20

  # instrument_method
  def index
    return raise_not_authorized(LoginMenuItem) unless RedisCache.cached_policy(@current_user, LoginMenuItem, 'index')
    login_menu_items = @str_prms[:location_id] ? policy_scope(LoginMenuItem).where(location: @str_prms[:location_id].to_i) : policy_scope(LoginMenuItem)
    items_count = login_menu_items.pluck(:id).count
    login_menu_items = login_menu_items.order(:id).page(@page).per(@itemsOnPage)
    render json: {
      data: {
        itemsOnPage: @itemsOnPage,
        login_menu_items: login_menu_items,
        items_count: items_count,
        can_create: RedisCache.cached_policy(current_user, LoginMenuItem, 'create')
      },
      status: 'ok',
      message: 'login_menu_items list'
    }
  end

  # instrument_method
  def show
    return raise_not_authorized(@login_menu_item) unless RedisCache.cached_policy(@current_user, @login_menu_item, 'show')
    render json: success(@login_menu_item, 'show')
  end

  # instrument_method
  def create
    return raise_not_authorized(LoginMenuItem) unless RedisCache.cached_policy(@current_user, LoginMenuItem, 'create')
    login_menu_item = LoginMenuItem.new(login_menu_item_params)
    login_menu_item.location_id = login_menu_item_params[:location_id]
    login_menu_item.title_en = login_menu_item_params[:title_en]
    login_menu_item.title_ru = login_menu_item_params[:title_ru]
    login_menu_item.url = login_menu_item_params[:url]
    login_menu_item.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.login_menu_items.#{k}") } } unless login_menu_item.save
    RedisCache.flush('location_style', login_menu_item.location_id)
    render json: success(login_menu_item, 'created')
  end

  # instrument_method
  def update
    return raise_not_authorized(@login_menu_item) unless RedisCache.cached_policy(@current_user, @login_menu_item, 'update')
    @login_menu_item.url = login_menu_item_params[:url]
    @login_menu_item.title_en = login_menu_item_params[:title_en]
    @login_menu_item.title_ru = login_menu_item_params[:title_ru]
    @login_menu_item.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.login_menu_items.#{k}") } } unless @login_menu_item.update(login_menu_item_params)
    RedisCache.flush('location_style', @login_menu_item.location_id)
    render json: success(@login_menu_item, 'updated')
  end

  # instrument_method
  def destroy
    return raise_not_authorized(@login_menu_item) unless RedisCache.cached_policy(@current_user, @login_menu_item, 'destroy')
    @login_menu_item.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.login_menu_items.#{k}") } } unless @login_menu_item.destroy
    RedisCache.flush('location_style', @login_menu_item.location_id)
    render json: success(nil, 'deleted')
  end

  private

  def success(login_menu_item, action)
    {
      data: { login_menu_item: login_menu_item },
      status: 'ok',
      message: I18n.t("errors.login_menu_items.#{action}")
    }
  end

  def parse_params
    @page = @str_prms[:page].to_i || 1
    @page = 1 if @page < 1
    @itemsOnPage = @str_prms[:itemsOnPage] || PAGESIZE
  end

  def current_login_menu_item
    @login_menu_item = LoginMenuItem.find_by(id: @str_prms[:id])
  end

  def login_menu_item_params
    params.require(:login_menu_item).permit(:location_id, :title_en, :title_ru, :url)
  end
end
