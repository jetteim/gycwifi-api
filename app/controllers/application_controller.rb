# метод normalize_params надо переопределять в тех контроллерах, куда в параметрах приходят объекты через GET запросы
class ApplicationController < ActionController::API
  # protect_from_forgery with: :null_session

  include Pundit
  include Skylight::Helpers
  include ActionController::Helpers

  respond_to :json
  before_action :set_origin
  before_action :set_headers
  before_action :authenticate_user
  before_action :set_locale
  before_action :normalize_params
  # before_action :ensure_json_request

  ALLOWED_HOSTS = %w[
    lvh.me localhost
    gycwifi.com enter.gycwifi.com
    api.gycwifi.com auth.gycwifi.com dashboard.gycwifi.com hal.gycwifi.com login.gycwifi.com
    api2.gycwifi.com auth2.gycwifi.com dashboard2.gycwifi.com hal2.gycwifi.com login2.gycwifi.com
    api3.gycwifi.com auth3.gycwifi.com dashboard3.gycwifi.com hal3.gycwifi.com login3.gycwifi.com
  ].freeze

  if Rails.env.production?
    rescue_from StandardError do |exception|
      production_exception_handler(exception)
    end
  end

  if Rails.env.staging?
    rescue_from StandardError do |exception|
      staging_exception_handler(exception)
    end
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    forbidden_handler(exception)
  end

  protected

  def raise_not_authorized(record, query = nil)
    query ||= @str_prms[:action].to_s
    user_not_authorized("User #{@current_user.inspect} not authorized to #{query} #{record.inspect}")
  end

  instrument_method
  def forbidden_handler(exception)
    user_not_authorized(exception.message)
  end

  instrument_method
  def authenticate_user
    user_not_authenticated unless authenticated_user?
  end

  def user_not_authorized(_message = nil)
    render json: { status: 'error', message: I18n.t('errors.permission_denied') }, status: :forbidden
  end

  def user_not_authenticated(message = nil)
    render json: { status: 'error', message: message }, status: :unauthorized
  end

  def set_origin
    @origin = request.headers['HTTP_ORIGIN']
  end

  def set_headers
    if @origin
      ALLOWED_HOSTS.each do |host|
        if @origin =~ %r{/^https?:\/\/#{Regexp.escape(host)}/i}
          headers['Access-Control-Allow-Origin'] = @origin
          break
        end
      end
    else
      # or '*' for public access
      headers['Access-Control-Allow-Origin'] = '*'
    end
    headers['Access-Control-Allow-Methods'] = '*'
    # headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept'
    headers['Content-Type'] = 'application/json'
  end

  def options
    head status: 200, 'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept'
  end

  def production_exception_handler(exception)
    logger.warn "production exception: #{exception.inspect}".red.bold
    render json: { status: 'error', message: exception.message }
    raise exception
  end

  def staging_exception_handler(exception)
    logger.warn "staging exception: #{exception.inspect}".red.bold
    render json: { status: 'error', message: exception.message }
    raise exception
  end

  instrument_method
  def current_user
    @current_user ||= token_user
  end
  helper_method :current_user

  instrument_method
  def authenticated_user?
    current_user.present?
  end
  helper_method :authenticated_user?

  instrument_method
  def unauthenticated_user?
    current_user.nil?
  end
  helper_method :unauthenticated_user?

  def permission_denied(message = nil)
    render json: { head: :forbidden, status: 'error', message: message }
  end
  helper_method :permission_denied

  instrument_method
  def set_locale
    I18n.locale = @current_user ? @current_user[:lang].to_sym : I18n.default_locale
  end

  instrument_method
  def normalize_params
    params.permit!
    @str_prms = params.to_h.deep_symbolize_keys
    logger.info "normalized params #{@str_prms.inspect}".cyan
  end

  def token_user
    token = Token.new(header_token)
    return unless token.valid?
    user = User.find(token.user_id)
    # пускаем под admin@example.com всегда на любой не-production среде
    return user if Rails.env.production? && user.pluck(:username, :email).includes?('admin@example.com')
    user if REDIS.smembers(redis_token_key(user.id)).include? header_token
  end

  def header_token
    request.headers['Authorization'].to_s.split.last
  end

  def redis_token_key(user_id)
    "token_#{user_id}"
  end

  def skip_bullet
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = true
  end
end
