# Library for radius tickets
class RadiusTicket
  # include Skylight::Helpers

  # instrument_method
  def self.create(session)
    # authorize end user on the router
    location = RedisCache.cached_location(session[:location_id]) unless session[:auth_expiration_time]
    AuthLog.find_or_create_by(username: session[:username]) do |auth_log|
      auth_log.username = session[:username]
      auth_log.password = session[:password]
      auth_log.client_device_id = session[:client_device_id]
      auth_log.timeout = session[:auth_expiration_time] || location[:auth_expiration_time]
      auth_log.voucher_id = session[:voucher_id]
    end
  end
end
