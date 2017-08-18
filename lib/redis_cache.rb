# Класс для хранения часто загружаемых объектов в REDIS кэше
class RedisCache
  include Pundit
  include Skylight::Helpers

  LOCATION_LIFETIME = 15.minutes
  VOUCHER_LIFETIME = 2.minutes
  ROUTER_LIFETIME = 15.minutes
  BRAND_LIFETIME = 3.hours
  POLICY_LIFETIME = 3.hours
  LAYOUT_LIFETIME = 24.hours
  POLL_LIFETIME = 2.hours
  USER_LIFETIME = 2.hours
  TOKEN_LIFETIME = 24.hours

  instrument_method
  def self.cached_location(location_id)
    cache_object('location', location_id, 'id',
                 methods: %i[extended_address template address_completed
                             phone_completed logo_uploaded url_completed
                             auth_count routers_count providers
                             available_vouchers],
                 include: [:login_menu_items])
  end

  instrument_method
  def self.user_token(user_id)
    key = "user_token_#{user_id}"
    REDIS.get(key)
  end

  instrument_method
  def self.store_token(user_id, token = nil)
    key = "user_token_#{user_id}"
    token ||= Token.encode(user_id)
    REDIS.set(key, token)
  end

  instrument_method
  def self.cached_poll(poll_id)
    cache_object('poll', poll_id, 'id', include: [questions: { include: [answers: { methods: [:attempts_count] }] }])
  end

  instrument_method
  def self.cached_brand(brand_id)
    cache_object('brand', brand_id, 'id', methods: [:template])
  end

  instrument_method
  def self.cached_router(router_common_name)
    cache_object('router', router_common_name, 'common_name', methods: %i[wan wlan])
  end

  instrument_method
  def self.cached_layout(layout_id)
    cache_object('layout', layout_id)
  end

  instrument_method
  def self.cached_user(user_id)
    cache_object('user', user_id)
  end

  instrument_method
  def self.flush(object, id)
    Rails.logger.debug "flushing cache for #{object} with id=#{id}".blue
    REDIS.del("cached_#{object}_#{id}")
  end

  instrument_method
  def self.cached_location_style(session)
    key = "cached_location_style_#{session[:location_id]}"
    return cached_style(key, session[:client_id]) if REDIS.exists(key)
    location = cached_location(session[:location_id])
    user = cached_user(location[:user_id])
    location[:sms_auth] = (user[:sms_count] > 0) if location[:sms_auth]
    poll = RedisCache.cached_poll(location[:poll_id]) if location[:poll_id]
    cache = style_hash(location, poll, session[:client_id])
    REDIS.setex(key, 10.minutes, cache.to_json)
    cache
  end

  instrument_method
  def self.cached_policy(current_user, resource, action = nil)
    s = resource.is_a?(Class) ? resource.to_s : resource.class.to_s
    id = resource.is_a?(Class) ? resource.to_s : resource.id
    key = "cached_policy_#{current_user[:id]}_#{s}_#{id}"
    if REDIS.exists(key)
      cached = JSON.parse(REDIS.get(key), symbolize_names: true)
    else
      # policy_name = resource.is_a?(Class) ? resource.to_s : resource.class.to_s
      # policy_class = Object.const_get("#{policy_name.capitalize}Policy")
      user = User.find_by(id: current_user[:id])
      policy = PolicyFinder.new(resource).policy
      permissions = policy.new(user, resource)
      cached = {}
      cached[:index] = permissions.index? if resource.is_a?(Class)
      cached[:create] = permissions.create? if resource.is_a?(Class)
      cached[:show] = permissions.show? unless resource.is_a?(Class)
      cached[:update] = permissions.update? unless resource.is_a?(Class)
      cached[:destroy] = permissions.destroy? unless resource.is_a?(Class)
      REDIS.setex(key, POLICY_LIFETIME, cached.to_json)
    end
    action ? cached[action.to_sym] : cached
  end

  private

  instrument_method
  def self.cached_style(key, client_id)
    cached = JSON.parse!(REDIS.get(key), symbolize_names: true)
    Rails.logger.debug "loaded location style from cache #{cached.inspect}".cyan
    poll = cached[:poll] if cached[:last_page_content] == 'poll'
    if no_poll?(client_id, poll)
      cached[:last_page_content] = 'text'
      cached[:poll] = nil
    end
    cached
  end

  instrument_method
  def self.style_hash(location, poll, client_id)
    no_poll = no_poll?(client_id, poll)
    {
      location_id: location[:id], title: location[:title],
      background: location[:background], promo_text: location[:promo_text],
      social_networks: location[:providers], logo: location[:logo],
      sms_auth: location[:sms_auth],
      vouchers: location[:available_vouchers], template: location[:template],
      login_menu_items: location[:login_menu_items],
      last_page_content: no_poll ? 'text' : location[:last_page_content],
      poll: no_poll ? nil : poll
    }
  end

  instrument_method
  def self.no_poll?(client_id, poll)
    return true unless poll
    return false unless poll[:run_once]
    return true unless questions = poll[:questions]
    answers = []
    questions.each do |question|
      question[:answers].each { |answer| answers << answer[:id] if answer } if question && question[:answers]
    end
    Attempt.exists?(client_id: client_id, answer_id: answers)
  end

  instrument_method
  def self.cache_object(name, id, id_attribute = 'id', json_params = nil)
    Rails.logger.debug "cache object #{name}, #{id_attribute}, #{id}".blue
    key = "cached_#{name}_#{id}"
    Rails.logger.debug "Redis key: #{key}".blue
    return cached = JSON.parse(REDIS.get(key), symbolize_names: true) if REDIS.exists(key)
    tmp = Object.const_get(name.capitalize).find_by("#{id_attribute} = ?", id)
    cached = tmp.as_json(json_params) if tmp
    res = cached.to_json if cached
    REDIS.setex(key, const_get("#{name.upcase}_LIFETIME"), res) if res
    Rails.logger.debug "cached data: #{cached.inspect}".blue
    cached.symbolize_keys if cached
  end

  instrument_method
  def self.use(key:, lifetime: 15.minutes)
    return JSON.parse(REDIS.get(key), symbolize_names: true) if REDIS.exists(key)
    data = yield
    REDIS.setex(key, lifetime, data.to_json)
    data
  end
end
