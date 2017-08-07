module Login
  require 'uri'
  # Login auth controller
  class AuthController < ApplicationController
    include Skylight::Helpers
    skip_before_action :authenticate_user
    # TODO: Вынести в .env
    GMAP_API_KEY = 'AIzaSyDjGQWbZqBJYHUd-W3MyLIiHrFV_lYU-1k'.freeze
    GMAP_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze

    TEMP_CLIENT_ID = 42
    REPLY_OK = {
      data: {
        status: 'ok',
        message: 'Thank you for your answer!'
      }
    }.freeze

    # 1. Точка входа
    instrument_method
    def location_style
      session = receive_data_from_router(@str_prms)
      json = NextStep.render_json_output(session)
      render json: json
    end

    instrument_method
    def poll_results
      interview_uuid = SecureRandom.uuid
      return unless (questions = @str_prms[:questions])
      logger.info "получены результаты опроса #{questions.inspect}".green
      # Перебираем все полученные ответы
      questions.each do |question|
        # Перебираем все полученные ответы на вопросы...
        logger.debug "poll question - #{question.inspect}".cyan
        answers = question[:answers]
        logger.debug "question answers: #{answers.inspect}".cyan
        next unless answers
        answers.each do |answer|
          # ...и создаём Attempt
          next unless answer
          Attempt.create(
            poll_id:        @str_prms[:poll_id],
            client_id:      @str_prms[:client_id],
            question_id:    question[:id],
            answer_id:      answer[:id],
            interview_uuid:   interview_uuid,
            custom_answer:  answer[:custom_answer]
          )
        end
        # end
      end
    ensure
      return render json: REPLY_OK
    end

    private

    instrument_method
    def receive_data_from_router(params)
      router_data = MikroTik.fromCACHE(params)
      logger.info "запрос на авторизацию от роутера #{router_data.inspect}".yellow
      router = RedisCache.cached_router(router_data[:nas_cn])
      if (client_device = ClientDevice.find_by(mac: router_data[:mac]))
        # если client_id == TEMP_CLIENT_ID - создаём для этого устройства нового клиента и обновляем ClientDevice
        if client_device.client_id == TEMP_CLIENT_ID
          client = Client.create
          client_device.update(client_id: client.id)
        else
          client = Client.find_or_create_by(id: client_device.client_id)
        end
      else
        client = Client.create
        client_device = create_client_device_by(router_data, client.id)
      end
      location = RedisCache.cached_location(router[:location_id])
      user = RedisCache.cached_user(location[:user_id])
      redirect_url = location[:redirect_url] if location
      {
        client_id: client.id,
        client_device_id: client_device.id,
        mac: client_device.mac,
        router_id: router[:id],
        common_name: router_data[:nas_cn],
        serial: router_data[:nas_serial],
        client_ip: router_data[:ip],
        username: SecureRandom.uuid.to_s,
        password: SecureRandom.hex(8),
        url: redirect_url || 'https://gycwifi.com',
        location_id: router[:location_id],
        sms_auth: location[:sms_auth] && user[:sms_count]
      }
    end

    instrument_method
    def create_client_device_by(router_data, client_id)
      ClientDevice.create(
        mac:              router_data[:mac],
        platform_os:      platform_os(router_data[:platform_os]),
        platform_product: platform_product(router_data[:platform_product]),
        client_id:        client_id
      )
    end

    def platform_os(platform_os)
      platform_os.blank? ? 'Unknown' : platform_os
    end

    def platform_product(platform_product)
      platform_product.blank? ? 'Unknown' : platform_product
    end
  end
end
