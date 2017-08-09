# Next step library
class NextStep
  include Skylight::Helpers
  GMAP_API_KEY = 'AIzaSyDjGQWbZqBJYHUd-W3MyLIiHrFV_lYU-1k'.freeze
  GMAP_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze

  # если у клиента есть номер телефона - проверяем, нужно ли обновить авторизацию через соцсеть
  # если номера нет - отправляем на страницу ввода телефона или на страницу подтверждения
  instrument_method
  def self.first_step(session)
    client = Client.find_or_create_by(id: session[:client_id])
    return refresh_social_account(session) if client.phone_number
    return 'authpending' if DeviceAuthPending.exists?(mac: session[:mac])
    'phone'
  end

  # если клиент авторизовался через соцсеть не больше месяца назад - авторизуем его
  # если нет - то отправляем авторизоваться
  instrument_method
  def self.refresh_social_account(session)
    location = RedisCache.cached_location(session[:location_id])
    providers = location[:providers]
    return 'providers' if providers[:voucher]
    social_account = SocialAccount.where(client_id: session[:client_id]).where.not(provider: :password).where("now() < updated_at + interval '1 month'").last
    return 'internet' if social_account && authorize(social_account, session)
    'providers'
  end

  # создаём или обновляем запись в client_tracker
  # создаём запись в social_log
  instrument_method
  def self.authorize(social_account, session)
    Rails.logger.info "авторизуем сессию #{session.inspect}".magenta
    # создаём новый трекер не чаще, чем раз в шесть часов, и не меньше, чем
    # через час после последнего инкремента
    tracker = client_tracker(session[:client_id], session[:location_id])
    tracker.increment!(:counter)
    SocialLog.create(
      social_account_id:  social_account.id,
      provider:           social_account.provider,
      location_id:        session[:location_id],
      router_id:          session[:router_id]
    )
    RadiusTicket.create(session)
  end

  instrument_method
  def self.render_json_output(destination = nil, session)
    session[:url] ||= 'https://gycwifi.com'
    session[:next_step] = destination || first_step(session)
    @session = session
  end

  instrument_method
  def self.login_session_client(session)
    session
  end

  instrument_method
  def self.login_session_style(session)
    RedisCache.cached_location_style(session)
  end

  instrument_method
  def self.login_session_targeting(session)
    targeting_info(session)
  end

  def self.login_session_css
    {}
  end

  instrument_method
  def self.login_session_router(session)
    session
  end

  instrument_method
  def self.login_session_poll(session)
    login_session_style(session)[:poll]
  end

  instrument_method
  def self.client_tracker(client_id, location_id)
    ClientCounter.find_or_create_by(
      client_id: client_id,
      location_id: location_id,
      updated_at: DateTime.current.ago(1.hour)..DateTime.current,
      created_at: DateTime.current.ago(6.hours)..DateTime.current
    ) do |tracker|
      tracker.client_id = client_id
      tracker.location_id = location_id
      tracker.save!
    end
  end

  instrument_method
  def self.targeting_info(session)
    targeting = {
      adDivId: "smt-130299538",
      publisherId: 1100021743,
      adSpaceId: 130299538,
      format: "all",
      formatstrict: true,
      dimension: "xlarge",
      width: 300,
      height: 50,
      sync: false
    }
    begin
      # собираем имеющиеся данные
      location = RedisCache.cached_location(session[:location_id])
      client = Client.find_by(id: session[:client_id])
      social_account = SocialAccount.where(client_id: client.id).where.not(provider: :password).last if client
      if social_account
        targeting[:gender] = social_account.gender if social_account.gender
        if social_account.bdate_year
          now = DateTime.current
          birthday = Date.new(social_account.bdate_year, social_account.bdate_month || 1, social_account.bdate_day || 1)
          user_age = now.year - birthday.year - (birthday.to_date.change(year: now.year) > now ? 1 : 0)
          targeting[:age] = user_age
        end
      end
      # geolocation
      if location[:address]
        geocoding =
          RestClient.get(
            URI.escape("#{GMAP_API_URL}?address=#{location[:address]}&key=#{GMAP_API_KEY}")
          )
      end
      geocoding = JSON.parse(geocoding, symbolize_names: true)
      lookup_results = geocoding[:results][0] if geocoding[:status] == 'OK'
      if lookup_results
        geo_location = lookup_results[:geometry][:location] if lookup_results[:geometry]
        if geo_location
          targeting[:lat] = geo_location[:lat]
          targeting[:lng] = geo_location[:lng]
        end
        lookup_results[:address_components].each do |address|
          targeting[:zip] = address[:long_name] unless targeting[:zip] || !address[:types].include?('postal_code')
          targeting[:country] = address[:long_name] unless targeting[:country] || !address[:types].include?('country')
          targeting[:city] = address[:long_name] unless targeting[:city] || !address[:types].include?('locality')
          targeting[:region] = address[:long_name] unless targeting[:region] || !address[:types].include?('administrative_area_level_1')
        end
      end
      Rails.logger.debug "targeting info for user #{client.id} at location #{location[:id]}: #{targeting}".yellow
      targeting
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.warn e.backtrace.join("\n")
      Rails.logger.debug "targeting info for user #{client.id} at location #{location[:id]}: #{targeting}".yellow
      targeting
    end
  end
end
