class AuthController < ApplicationController #:nodoc:
  # # include Skylight::Helpers
  skip_before_action :authenticate_user

  # instrument_method
  def authenticate
    subdomain = @str_prms[:redirectUri].split('.').first if @str_prms[:redirectUri]
    target = subdomain =~ /dashboard.*/ ? 'user' : 'client'
    send("authorize_#{target}".to_sym, @str_prms)
  end

  # авторизация на dashboard. конечная цель здесь - отдать на frontend токен, в котором зашифрован user.id.
  # этот же токен мы кладём в redis по ключу user_token_#{user_id} и когда с фронтенда приходит токен,
  # мы по нему можем восстановить user_id и сравнить токен в redis с пришедшим от фронтенда
  # для того, чтобы всё это сделать, нам нужно получить от соцсети uid пользователя
  # чтобы по нему найти или создать SocialAccount, а по нему уже - связанного пользователя
  # поэтому здесь мы должны дождаться ответа от соцсетки и только потом отдать управление
  # instrument_method
  def authorize_user(params)
    auth_data = auth_params(params)
    return password(params) if auth_data[:provider] == 'password'
    user_data = SocialAccount.pull_user_data(auth_data)
    social_account = SocialAccount.find_social_account(user_data)
    user = social_account.linked_user
    render json: user.profile, status: :ok
  end

  # авторизация в login - мы уже идентифицировали нашего Client, а для его авторизации достаточно того,
  # что у нас есть access_code. Наша задача - по этому access_code вытащить инфу о клиенте и положить в базу,
  # а также авторизовать его на Radius и отправить в интернет
  # эти задачи в принципе не зависят друг от друга, поэтому мы вынесем в delayed_job
  # запрос к соцсети, парсинг, создание/обновление социального аккаунта и запись в лог
  # instrument_method
  def authorize_client(params)
    @auth_data = auth_params(params)
    @session = login_params[:session]
    logger.info "авторизуем клиента #{@session[:client_id]} с данными авторизации #{@auth_data}".green
    logger.debug "session data: #{@session.inspect}".magenta
    authorized = authorization_required? ? verify_authorization : true
    RadiusTicket.create(@session) if authorized
    SocialNetworkProfileReader.perform_later(@auth_data, @session) if authorized
    response = NextStep.render_json_output(authorized ? 'internet' : 'providers', @session)
    render json: response, status: :ok
  end

  # Via password
  # instrument_method
  def password(params)
    if params[:username] && User.find_by(sign_in_params).nil?
      sign_up
      logger.debug "password sign-up with params #{sign_in_params.inspect}".yellow
    else
      sign_in
    end
  end

  # Sign in part
  # instrument_method
  def sign_in
    logger.debug "password sign-in with params #{sign_in_params.inspect}".yellow
    user = sign_in_user
    if user
      logger.debug "found user #{user.inspect}".yellow
      render json: user.profile, status: :created
    else
      render json: { auth: false, error: 'Cant find user' }, status: :unprocessable_entity
    end
  end

  # Sign Up part
  # instrument_method
  def sign_up
    user = build_user
    if user.save
      logger.debug "new user created #{user.inspect}".yellow
      render json: user.profile
      perform_sign_up_job(user)
    else
      render json: { error: user.errors.full_messages }
    end
  end

  private

  def authorization_required?
    # TODO: здесь надо бы сделать диспетчер
    return true if @auth_data[:provider] == 'voucher'
  end

  def verify_authorization
    # TODO: здесь надо бы сделать диспетчер
    return verify_voucher if @auth_data[:provider] == 'voucher'
  end

  # instrument_method
  def verify_voucher
    logger.info "проверяем ваучер #{@auth_data[:access_code]}".yellow
    # загружаем локацию из кэша
    location = RedisCache.cached_location(@session[:location_id])
    # ищем среди действительных ваучеров
    logger.debug "location #{location[:title]} has available vouchers: #{vouchers = location[:available_vouchers]}".blue
    match = vouchers.select { |v| v[:password].casecmp(@auth_data[:access_code].upcase).zero? && !v[:expired] }
    logger.debug "user entered #{@auth_data[:access_code]}, filter result #{match.inspect}".green
    voucher = match.last
    unless voucher
      logger.info 'среди действующих ваучеров такого не нашли'.red
      @session[:voucher_error] = I18n.t('errors.vouchers.not_found')
      return false
    end
    if voucher[:activated] && (voucher[:client_id] != @session[:client_id])
      # с этим ваучером уже зашёл кто-то другой
      logger.info "ваучер действующий, но его уже использовал клиент #{voucher.client_id}".red
      @session[:voucher_error] = I18n.t('errors.vouchers.activated')
      return false
    end
    @session[:voucher_id] = voucher[:id]
    if voucher[:activated]
      # авторизуем на время, оставшееся по ваучеру
      remaining = ((Time.zone.parse(voucher[:expiration]) - DateTime.current) * 86_400).to_i
      logger.info "по этому ваучеру уже заходили, авторизуем клиента до #{Time.zone.parse(voucher[:expiration])}," /
                  "текущее время #{DateTime.current}, осталось секунд #{remaining}".yellow
      @session[:auth_expiration_time] = remaining
    else
      voucher = Voucher.find_by(id: voucher[:id])
      logger.info "активируем новый ваучер #{voucher.inspect}".green
      @session[:auth_expiration_time] = voucher.duration ? 60 * voucher.duration : location[:auth_expiration_time]
      voucher.activate(@session[:client_id])
    end
    true
  end

  # instrument_method
  def auth_params(params)
    {
      provider: params[:provider],
      access_code: params[:code],
      redirect_url: params[:redirectUri]
    }
  end

  def sign_in_params
    params.permit(:email, :password)
  end

  def sign_up_params
    params.permit(:username, :email, :password, :promo_code)
  end

  def login_params(params = nil)
    params ||= @str_prms
    res = JSON.parse(params[:params]).deep_symbolize_keys if params[:params].is_a? String
    res ||= params[:params]
    logger.debug "parsed login params: #{res}".cyan
    res
  end

  def sign_in_user
    return User.find_by(sign_in_params) if %w[production test].include? Rails.env
    User.find_by(email: sign_in_params[:email])
  end

  def perform_sign_up_job(user)
    SignupMailer.signup_email(user).deliver_later
    AdvertisementMailer.advertisement_email(user).deliver_later
  end

  def build_user
    promo_code = PromoCode.find_by(code: sign_up_params[:promo_code])
    User.new(sign_up_params.merge(promo_code: promo_code))
  end
end
