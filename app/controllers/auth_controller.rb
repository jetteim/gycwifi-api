class AuthController < ApplicationController
  include Skylight::Helpers
  skip_before_action :authenticate_user

  instrument_method
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
  instrument_method
  def authorize_user(params)
    auth_data = auth_params(params)
    return password(params) if auth_data[:provider] == 'password'
    user_data = SocialAccount.pull_user_data(auth_data)
    social_account = SocialAccount.find_social_account(user_data)
    user = social_account.linked_user
    render json: {
      auth: true,
      username: user.username,
      email: nil,
      avatar: user.avatar,
      token: token(user.id)
    }, status: 200
  end

  # авторизация в login - мы уже идентифицировали нашего Client, а для его авторизации достаточно того, что у нас есть access_code
  # наша задача - по этому access_code вытащить инфу о клиенте и положить в базу, а также авторизовать его на Radius и отправить в интернет
  # эти задачи в принципе не зависят друг от друга, поэтому мы вынесем в delayed_job
  # запрос к соцсети, парсинг, создание/обновление социального аккаунта и запись в лог
  instrument_method
  def authorize_client(params)
    @auth_data = auth_params(params)
    @session = params[:params][:session]
    logger.info "авторизовываем клиента #{@session[:client_id]} с данными авторизации #{@auth_data}".green
    logger.debug "session data: #{@session.inspect}".magenta
    authorized = authorization_required? ? verify_authorization : true
    RadiusTicket.create(@session) if authorized
    SocialNetworkProfileReader.perform_later(@auth_data, @session) if authorized
    render json: authorized ? NextStep.render_json_output('internet', @session) : NextStep.render_json_output('providers', @session)
  end

  # Via password
  instrument_method
  def password(params)
    params[:username] ? sign_up : sign_in
  end

  # Sign in part
  instrument_method
  def sign_in
    logger.debug "password sign-in with params #{sign_in_params.inspect}".yellow
    user = case Rails.env
           when 'production'
             User.find_by(sign_in_params)
           else
             User.find_by(email: sign_in_params[:email])
           end

    if user
      logger.debug "found user #{user.inspect}".yellow
      user_token = token(user.id)

      render json: {
        id: user.id,
        auth: true,
        username: user.username,
        email: user.email,
        avatar: checked_avatar(user),
        token: user_token,
        role: user.role
      }, status: 201
    else
      render json: { auth: false, error: 'Cant find user' }
    end
  end

  # Sign Up part
  instrument_method
  def sign_up
    logger.debug "password sign-up with params #{sign_in_params.inspect}".yellow
    user = User.find_by(sign_up_params)
    if user
      logger.debug "sign-in instead, found user #{user.inspect}".yellow
      user.update_attribute(avatar, '/images/avatars/default.jpg') unless user.avatar
      render json: auth_json(user), status: 201
    else
      user = User.new(sign_up_params)
      if user.save
        logger.debug "new user created #{user.inspect}".yellow
        render json: auth_json(user)
        SignupMailer.signup_email(user).deliver_later
        AdvertisementMailer.advertisement_email(user).deliver_later
      else
        render json: { error: user.errors.full_messages }
      end
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

  instrument_method
  def verify_voucher
    logger.info "проверяем ваучер #{auth_data[:access_code]}".yellow
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
      logger.info "по этому ваучеру уже заходили, авторизуем клиента до #{DateTime.parse(voucher[:expiration])}, текущее время #{DateTime.current}, осталось секунд #{remaining = ((DateTime.parse(voucher[:expiration]) - DateTime.current) * 86_400).to_i}".yellow
      @session[:auth_expiration_time] = remaining
    else
      voucher = Voucher.find_by(id: voucher[:id])
      logger.info "активируем новый ваучер #{voucher.inspect}".green
      @session[:auth_expiration_time] = voucher.duration ? 60 * voucher.duration : location[:auth_expiration_time]
      voucher.activate(@session[:client_id])
    end
    true
  end

  def auth_json(user)
    {
      id: user.id,
      auth: true,
      username: user.username,
      email: user.email,
      avatar: user.avatar,
      token: token(user.id)
    }
  end

  instrument_method
  def token(user_id)
    logger.debug "building token for user #{user_id}".cyan
    RedisCache.store_token(user_id, token = Token.encode(user_id))
    token
  end

  instrument_method
  def auth_params(_params)
    {
      provider: @str_prms[:provider],
      access_code: @str_prms[:code],
      redirect_url: @str_prms[:redirectUri]
    }
  end

  def sign_in_params
    params.permit(:email, :password)
  end

  def sign_up_params
    params.permit(:username, :email, :password)
  end

  def login_params
    @str_prms[:params]
  end

  def checked_avatar(user)
    # Если внутренний источник
    user.avatar
  end
end
