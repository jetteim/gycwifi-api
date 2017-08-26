class Dashboard::VouchersController < ApplicationController
  # include Skylight::Helpers
  before_action :current_voucher, only: %i[show update destroy]
  before_action :parse_params
  PAGESIZE = 20

  # instrument_method
  def index
    return raise_not_authorized(Voucher) unless RedisCache.cached_policy(@current_user, Voucher, 'index')
    vouchers = @str_prms[:location_id] ? policy_scope(Voucher).where(location: @str_prms[:location_id].to_i) : policy_scope(Voucher)
    items_count = vouchers.pluck(:id).count
    vouchers = vouchers.order(:id).page(@page).per(@itemsOnPage)
    render json: {
      data: {
        itemsOnPage: @itemsOnPage,
        vouchers: vouchers,
        items_count: items_count,
        can_create: RedisCache.cached_policy(current_user, Voucher, 'create')
      },
      status: 'ok',
      message: 'vouchers list'
    }
  end

  # instrument_method
  def show
    return raise_not_authorized(@voucher) unless RedisCache.cached_policy(@current_user, @voucher, 'show')
    render json: success(voucher, 'show')
  end

  # instrument_method
  def create
    return raise_not_authorized(Voucher) unless RedisCache.cached_policy(@current_user, Voucher, 'create')
    voucher = Voucher.new(voucher_params)
    voucher.location_id = voucher_params[:location_id]
    voucher.expiration = voucher_params[:expiration] || DateTime.current + 1.month
    voucher.password = voucher_params[:password] || SecureRandom.hex(4).upcase
    if voucher_params[:duration]
      voucher.duration = voucher_params[:duration]
    else
      location = Location.find_by(id: voucher.location_id)
      voucher.duration = location.auth_expiration_time / 60
    end
    voucher.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.vouchers.#{k}") } } unless voucher.save
    RedisCache.flush('location', voucher.location_id)
    render json: success(voucher, 'created')
  end

  # instrument_method
  def update
    return raise_not_authorized(@voucher) unless RedisCache.cached_policy(@current_user, @voucher, 'update')
    @voucher.password = voucher_params[:password]
    @voucher.duration = voucher_params[:duration] if voucher_params[:duration]
    @voucher.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.vouchers.#{k}") } } unless @voucher.update(voucher_params)
    RedisCache.flush('location', @voucher.location_id)
    render json: success(@voucher, 'updated')
  end

  # instrument_method
  def destroy
    return raise_not_authorized(@voucher) unless RedisCache.cached_policy(@current_user, @voucher, 'destroy')
    @voucher.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.vouchers.#{k}") } } unless @voucher.destroy
    RedisCache.flush('location', @voucher.location_id)
    render json: success(nil, 'deleted')
  end

  private

  def success(voucher, action)
    {
      data: { voucher: voucher },
      status: 'ok',
      message: I18n.t("errors.vouchers.#{action}")
    }
  end

  def parse_params
    @page = @str_prms[:page].to_i || 1
    @page = 1 if @page < 1
    @itemsOnPage = @str_prms[:itemsOnPage] || PAGESIZE
  end

  def current_voucher
    @voucher = Voucher.find_by(id: @str_prms[:id])
  end

  def voucher_params
    params.require(:voucher).permit(:expiration, :location_id, :password, :duration)
  end
end
