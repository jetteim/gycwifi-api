module Login
  # Phone controller
  class PhoneController < ApplicationController
    # include Skylight::Helpers
    before_action :parse_params
    skip_before_action :authenticate_user

    def availability_check
      render json: { method: 'post' }
    end

    # instrument_method
    def client_call_confirmation
      logger.info "callback от http://smsc.ru: #{@pending_message} с телефона #{@pending_phone}, попробуем сопоставить его с клиентом".yellow
      return head :ok unless @pending_message == '[CALL]'
      return head :ok unless (pending = DeviceAuthPending.find_by(phone: @pending_phone) || DeviceAuthPending.find_by(phone: @pending_phone[1..-1]))
      return head :ok unless (client_device = ClientDevice.find_by(mac: pending.mac))
      client = renew_client_phone(long_phone_number(pending.phone.to_s), client_device)
      logger.info "подтверждаем телефон #{@pending_phone} для клиента #{client.id}".green
      pending.assign_client(client.id)
      head :ok
    end

    # instrument_method
    def check_client_number
      render json: NextStep.render_json_output(@session)
    end

    # Запускаем процесс ожидания звонка от пользователя
    # instrument_method
    def pending_call_auth
      logger.info "новый телефонный номер #{@session[:phone_number]}, ожидает подтверждения".yellow
      # проверяем sms_count и отправляем смс, если можно
      location = Location.find_by(id: @session[:location_id])
      sms_code = send_sms(location, @session[:phone_number]) if @session[:phone_number] && location.user.sms_count > 0
      # добавляем запись в pending или обновляем телефон, если для устройства запись уже есть
      device_pending = DeviceAuthPending.find_or_create_by(mac: @session[:mac])
      device_pending.update(phone: long_phone_number(@session[:phone_number].to_s), sms_code: sms_code)
      @session[:phone_number] = device_pending.phone
      render json: NextStep.render_json_output('authpending', @session)
    end

    # instrument_method
    def verify_code
      logger.info "клиент ввёл код из смс #{@session.inspect}, проверяем".yellow
      # если пришёл параметр smsCode, то как будто мы его проверили и он как будто правильный
      return render json: NextStep.render_json_output('authpending', @session) unless (auth_pending = DeviceAuthPending.find_by(mac: @session[:mac]))
      return render json: NextStep.render_json_output(@session) if @session[:phone_number].blank? || @session[:sms_code].blank? || auth_pending.sms_code.blank?
      return render json: NextStep.render_json_output(@session) unless (device_pending = ClientDevice.find_by(mac: @session[:mac]))
      # и вот мы всё проверили - ок, подтверждаем номер
      client = renew_client_phone(@session[:phone_number], device_pending)
      @session[:client_id] = client.id
      auth_pending.assign_client(client.id)
      logger.info "подтверждаем и авторизуем сессию #{@session.inspect}".green
      NextStep.authorize(SocialAccount.where(client_id: client.id, provider: :password).first_or_create, @session)
      render json: NextStep.render_json_output('internet', @session)
    end

    # instrument_method
    def login_session_targeting
      render json: NextStep.login_session_targeting(@session)
    end

    # instrument_method
    def login_session_style
      render json: NextStep.login_session_style(@session)
    end

    # instrument_method
    def login_session_css
      render json: NextStep.login_session_css(@session)
    end

    # instrument_method
    def login_session_poll
      render json: NextStep.login_session_poll(@session)
    end

    # instrument_method
    def login_session_client
      render json: NextStep.login_session_client(@session)
    end

    # instrument_method
    def login_session_router
      render json: NextStep.login_session_router(@session)
    end

    private

    # instrument_method
    def long_phone_number(phone_number)
      result = phone_number.gsub(/[^\d,\.]/, '')
      case result.length
      when 10
        result = "7#{result}"
        logger.debug "using phone #{result} instead of #{phone_number}".cyan
      when 11
        result[0] = '7' if result[0] == '8'
      end
      result
    end

    # instrument_method
    def short_phone_number(phone_number)
      raw_phone = phone_number.gsub(/[^\d,\.]/, '')
      raw_phone[1..-1] if raw_phone.length == 11
    end

    # instrument_method
    def renew_client_phone(phone_number, client_device)
      logger.info "у нас новое устройство #{client_device.id} с телефоном #{phone_number}, ищем дубликаты".yellow
      existing_client = Client.find_by(phone_number: long_phone_number(phone_number.to_s))
      confirmed_client = client_device.client
      return confirmed_client unless existing_client
      return confirmed_client if confirmed_client == existing_client
      # если номер телефона есть в базе - надо удалить confirmed_client
      # и использовать вместо него существующий
      logger.info "номер телефона #{phone_number} найден у клиента #{existing_client.inspect}, используем его вместо #{confirmed_client.inspect}".red.bold
      confirmed_client.client_devices.each { |device| device.update(client: existing_client) }
      confirmed_client.social_accounts.each { |account| account.update(client: existing_client) }
      confirmed_client.delete
      @session[:client_id] = existing_client.id
      existing_client
    end

    def parse_params
      @pending_phone = @str_prms[:phone] ? long_phone_number(@str_prms[:phone].to_s) : nil
      @pending_message = @str_prms[:mes] ? @str_prms[:mes].to_s : nil
      @session = {
        client_id: @str_prms[:client_id],
        client_device_id: @str_prms[:client_device_id],
        mac: @str_prms[:mac],
        router_id: @str_prms[:router_id],
        phone_number: @str_prms[:phone_number],
        sms_code: @str_prms[:sms_code],
        common_name: @str_prms[:common_name],
        serial: @str_prms[:serial],
        client_ip: @str_prms[:client_ip],
        username: @str_prms[:username],
        password: @str_prms[:password],
        url: @str_prms[:url],
        location_id: @str_prms[:location_id],
        apiUrl: @str_prms[:apiUrl],
        halUrl: @str_prms[:halUrl],
        platform_os: @str_prms[:platform_os],
        platform_product: @str_prms[:platform_product]
      }
    end

    # instrument_method
    def send_sms(location, phone)
      code = rand.to_s[2..5]
      if location && location.user && location.user.sms_count
        SmsSender.perform_later(code, phone)
        location.increment!(:sms_count)
        location.user.decrement!(:sms_count)
        RedisCache.flush('location_style', location.id)
        RedisCache.flush('location', location.id)
        RedisCache.flush('user', location.id)
      end
      code
    end
  end
end
