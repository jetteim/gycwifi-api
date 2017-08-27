# Класс для хранения часто загружаемых объектов в REDIS кэше
class RedisCache
  include Pundit
  # include Skylight::Helpers

  LOCATION_LIFETIME = 15.minutes
  VOUCHER_LIFETIME = 2.minutes
  ROUTER_LIFETIME = 15.minutes
  BRAND_LIFETIME = 3.hours
  POLICY_LIFETIME = 3.hours
  LAYOUT_LIFETIME = 24.hours
  POLL_LIFETIME = 2.hours
  USER_LIFETIME = 2.hours
  TOKEN_LIFETIME = 24.hours
  # colors
  # BG_PRIMARY_RGB = '92, 144, 210'
  # BG_FORM_LOGIN_RGB = '37, 40, 47'
  DEFAULT_BG_COLOR_HEX = '#5c90d2'
  DEFAULT_BG_COLOR_RGB = DEFAULT_BG_COLOR_HEX.paint.to_rgb
  DEFAULT_BG_COLOR_HEX8 = DEFAULT_BG_COLOR_HEX.paint.to_hex
  RED = { '50' => '#ffebee',
   '100' => '#ffcdd2',
   '200' => '#ef9a9a',
   '300' => '#e57373',
   '400' => '#ef5350',
   '500' => '#f44336',
   '600' => '#e53935',
   '700' => '#d32f2f',
   '800' => '#c62828',
   '900' => '#b71c1c',

   'A100' => '#ff8a80',
   'A200' => '#ff5252',
   'A400' => '#ff1744',
   'A700' => '#d50000',
  }

  PINK = {
      '50' => '#fce4ec',
      '100' => '#f8bbd0',
      '200' => '#f48fb1',
      '300' => '#f06292',
      '400' => '#ec407a',
      '500' => '#e91e63',
      '600' => '#d81b60',
      '700' => '#c2185b',
      '800' => '#ad1457',
      '900' => '#880e4f',

      'A100' => '#ff80ab',
      'A200' => '#ff4081',
      'A400' => '#f50057',
      'A700' => '#c51162',
  }

  PURPLE = {
      '50' => '#f3e5f5',
      '100' => '#e1bee7',
      '200' => '#ce93d8',
      '300' => '#ba68c8',
      '400' => '#ab47bc',
      '500' => '#9c27b0',
      '600' => '#8e24aa',
      '700' => '#7b1fa2',
      '800' => '#6a1b9a',
      '900' => '#4a148c',

      'A100' => '#ea80fc',
      'A200' => '#e040fb',
      'A400' => '#d500f9',
      'A700' => '#aa00ff',
  }

  DEEP_PURPLE = {
      '50' => '#ede7f6',
      '100' => '#d1c4e9',
      '200' => '#b39ddb',
      '300' => '#9575cd',
      '400' => '#7e57c2',
      '500' => '#673ab7',
      '600' => '#5e35b1',
      '700' => '#512da8',
      '800' => '#4527a0',
      '900' => '#311b92',

      'A100' => '#b388ff',
      'A200' => '#7c4dff',
      'A400' => '#651fff',
      'A700' => '#6200ea',
  }


  INDIGO = {

      '50' => '#e8eaf6',
      '100' => '#c5cae9',
      '200' => '#9fa8da',
      '300' => '#7986cb',
      '400' => '#5c6bc0',
      '500' => '#3f51b5',
      '600' => '#3949ab',
      '700' => '#303f9f',
      '800' => '#283593',
      '900' => '#1a237e',

      'A100' => '#8c9eff',
      'A200' => '#536dfe',
      'A400' => '#3d5afe',
      'A700' => '#304ffe',
  }

  BLUE = {
      '50' => '#e3f2fd',
      '100' => '#bbdefb',
      '200' => '#90caf9',
      '300' => '#64b5f6',
      '400' => '#42a5f5',
      '500' => '#2196f3',
      '600' => '#1e88e5',
      '700' => '#1976d2',
      '800' => '#1565c0',
      '900' => '#0d47a1',

      'A100' => '#82b1ff',
      'A200' => '#448aff',
      'A400' => '#2979ff',
      'A700' => '#2962ff',
  }

  LIGHT_BLUE = {
      '50' => '#e1f5fe',
      '100' => '#b3e5fc',
      '200' => '#81d4fa',
      '300' => '#4fc3f7',
      '400' => '#29b6f6',
      '500' => '#03a9f4',
      '600' => '#039be5',
      '700' => '#0288d1',
      '800' => '#0277bd',
      '900' => '#01579b',

      'A100' => '#80d8ff',
      'A200' => '#40c4ff',
      'A400' => '#00b0ff',
      'A700' => '#0091ea',
  }


  CYAN = {
      '50' => '#e0f7fa',
      '100' => '#b2ebf2',
      '200' => '#80deea',
      '300' => '#4dd0e1',
      '400' => '#26c6da',
      '500' => '#00bcd4',
      '600' => '#00acc1',
      '700' => '#0097a7',
      '800' => '#00838f',
      '900' => '#006064',

      'A100' => '#84ffff',
      'A200' => '#18ffff',
      'A400' => '#00e5ff',
      'A700' => '#00b8d4',
  }

  TEAL = {
      '50' => '#e0f2f1',
      '100' => '#b2dfdb',
      '200' => '#80cbc4',
      '300' => '#4db6ac',
      '400' => '#26a69a',
      '500' => '#009688',
      '600' => '#00897b',
      '700' => '#00796b',
      '800' => '#00695c',
      '900' => '#004d40',

      'A100' => '#a7ffeb',
      'A200' => '#64ffda',
      'A400' => '#1de9b6',
      'A700' => '#00bfa5',
  }

  GREEN = {
      '50' => '#e8f5e9',
      '100' => '#c8e6c9',
      '200' => '#a5d6a7',
      '300' => '#81c784',
      '400' => '#66bb6a',
      '500' => '#4caf50',
      '600' => '#43a047',
      '700' => '#388e3c',
      '800' => '#2e7d32',
      '900' => '#1b5e20',

      'A100' => '#b9f6ca',
      'A200' => '#69f0ae',
      'A400' => '#00e676',
      'A700' => '#00c853',
  }

  LIGHT_GREEN = {
      '50' => '#f1f8e9',
      '100' => '#dcedc8',
      '200' => '#c5e1a5',
      '300' => '#aed581',
      '400' => '#9ccc65',
      '500' => '#8bc34a',
      '600' => '#7cb342',
      '700' => '#689f38',
      '800' => '#558b2f',
      '900' => '#33691e',

      'A100' => '#ccff90',
      'A200' => '#b2ff59',
      'A400' => '#76ff03',
      'A700' => '#64dd17',
  }

  LIME = {
      '50' => '#f9fbe7',
      '100' => '#f0f4c3',
      '200' => '#e6ee9c',
      '300' => '#dce775',
      '400' => '#d4e157',
      '500' => '#cddc39',
      '600' => '#c0ca33',
      '700' => '#afb42b',
      '800' => '#9e9d24',
      '900' => '#827717',

      'A100' => '#f4ff81',
      'A200' => '#eeff41',
      'A400' => '#c6ff00',
      'A700' => '#aeea00',
  }

  YELLOW = {
      '50' => '#fffde7',
      '100' => '#fff9c4',
      '200' => '#fff59d',
      '300' => '#fff176',
      '400' => '#ffee58',
      '500' => '#ffeb3b',
      '600' => '#fdd835',
      '700' => '#fbc02d',
      '800' => '#f9a825',
      '900' => '#f57f17',

      'A100' => '#ffff8d',
      'A200' => '#ffff00',
      'A400' => '#ffea00',
      'A700' => '#ffd600',
  }

  AMBER = {

      '50' => '#fff8e1',
      '100' => '#ffecb3',
      '200' => '#ffe082',
      '300' => '#ffd54f',
      '400' => '#ffca28',
      '500' => '#ffc107',
      '600' => '#ffb300',
      '700' => '#ffa000',
      '800' => '#ff8f00',
      '900' => '#ff6f00',

      'A100' => '#ffe57f',
      'A200' => '#ffd740',
      'A400' => '#ffc400',
      'A700' => '#ffab00',
  }

  ORANGE = {
      '50' => '#fff3e0',
      '100' => '#ffe0b2',
      '200' => '#ffcc80',
      '300' => '#ffb74d',
      '400' => '#ffa726',
      '500' => '#ff9800',
      '600' => '#fb8c00',
      '700' => '#f57c00',
      '800' => '#ef6c00',
      '900' => '#e65100',

      'A100' => '#ffd180',
      'A200' => '#ffab40',
      'A400' => '#ff9100',
      'A700' => '#ff6d00',
  }

  DEEP_ORANGE = {
      '50' => '#fbe9e7',
      '100' => '#ffccbc',
      '200' => '#ffab91',
      '300' => '#ff8a65',
      '400' => '#ff7043',
      '500' => '#ff5722',
      '600' => '#f4511e',
      '700' => '#e64a19',
      '800' => '#d84315',
      '900' => '#bf360c',

      'A100' => '#ff9e80',
      'A200' => '#ff6e40',
      'A400' => '#ff3d00',
      'A700' => '#dd2c00',
  }

  BROWN = {
      '50' => '#efebe9',
      '100' => '#d7ccc8',
      '200' => '#bcaaa4',
      '300' => '#a1887f',
      '400' => '#8d6e63',
      '500' => '#795548',
      '600' => '#6d4c41',
      '700' => '#5d4037',
      '800' => '#4e342e',
      '900' => '#3e2723',
  }

  GREY = {
      '50' => '#fafafa',
      '100' => '#f5f5f5',
      '200' => '#eeeeee',
      '300' => '#e0e0e0',
      '400' => '#bdbdbd',
      '500' => '#9e9e9e',
      '600' => '#757575',
      '700' => '#616161',
      '800' => '#424242',
      '900' => '#212121',
  }

  BLUE_GREY = {
      '50' => '#eceff1',
      '100' => '#cfd8dc',
      '200' => '#b0bec5',
      '300' => '#90a4ae',
      '400' => '#78909c',
      '500' => '#607d8b',
      '600' => '#546e7a',
      '700' => '#455a64',
      '800' => '#37474f',
      '900' => '#263238',
  }

  BLACK = '#000000'
  WHITE = '#FFFFFF'
  # instrument_method
  def self.cached_location(location_id)
    cache_object('location', location_id, 'id',
                 methods: %i[extended_address template address_completed
                             phone_completed logo_uploaded url_completed
                             auth_count routers_count providers
                             available_vouchers],
                 include: [:login_menu_items])
  end

  # instrument_method
  def self.cached_poll(poll_id)
    cache_object('poll', poll_id, 'id', include: [questions: { include: [answers: { methods: [:attempts_count] }] }])
  end

  # instrument_method
  def self.cached_brand(brand_id)
    cache_object('brand', brand_id, 'id', methods: [:template])
  end

  # instrument_method
  def self.cached_router(router_common_name)
    cache_object('router', router_common_name, 'common_name', methods: %i[wan wlan])
  end

  # instrument_method
  def self.cached_layout(layout_id)
    cache_object('layout', layout_id)
  end

  # instrument_method
  def self.cached_location_style(session)
    key = "cached_location_style_#{session[:location_id]}"
    return cached_style(key, session[:client_id]) if REDIS.exists(key)
    location = cached_location(session[:location_id])
    if location[:sms_auth]
      user = User.find_by(id: location[:user_id])
      location[:sms_auth] = user.sms_count.positive?
    end
    poll = RedisCache.cached_poll(location[:poll_id]) if location[:poll_id]
    cache = style_hash(location, poll, session[:client_id])
    REDIS.setex(key, 10.minutes, cache.to_json)
    cache
  end

  # instrument_method
  def self.cached_policy(current_user, resource, action = nil)
    s = resource.is_a?(Class) ? resource.to_s : resource.class.to_s
    id = resource.is_a?(Class) ? resource.to_s : resource.id
    key = "cached_policy_#{current_user.id}_#{s}_#{id}"
    if REDIS.exists(key)
      cached = JSON.parse(REDIS.get(key), symbolize_names: true)
    else
      # policy_name = resource.is_a?(Class) ? resource.to_s : resource.class.to_s
      # policy_class = Object.const_get("#{policy_name.capitalize}Policy")
      user = User.find_by(id: current_user.id)
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

  # instrument_method
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

  # instrument_method
  def self.style_hash(location, poll, client_id)
    no_poll = no_poll?(client_id, poll)
    {
      location_id: location[:id], title: location[:title],
      background: location[:background], promo_text: location[:promo_text],
      social_networks: location[:providers], logo: location[:logo],
      sms_auth: location[:sms_auth], bg_color: location[:bg_color] || DEFAULT_BG_COLOR_HEX8,
      color_theme: build_palette(location[:bg_color]),
      vouchers: location[:available_vouchers], template: location[:template],
      login_menu_items: location[:login_menu_items],
      redirect_url: location[:redirect_url],
      last_page_content: no_poll ? 'text' : location[:last_page_content],
      poll: no_poll ? nil : poll
    }
  end

  def self.build_palette(base_color)
    tetrad = base_color.paint.palette.tetrad
    form_base_color = tetrad[0]
    gradient_base_color = tetrad[1]
    form_secondary_color = tetrad[2]
    form_alternate_color = tetrad[3]
    form_primary_text_color = form_base_color.paint.dark? ? '#FFFFFF' : '#000000'
    form_secondary_text_color = form_secondary_color.paint.dark? ? '#FFFFFF' : '#000000'
    form_alternate_text_color = form_alternate_color.paint.dark? ? '#FFFFFF' : '#000000'
    gradient_start = form_base_color.paint
    gradient_start.rgb.a = 0.6
    gradient_end = form_base_color.paint
    gradient_end.rgb.a = 0.8
    form_primary_color = form_base_color.paint
    form_primary_color.rgb.a = 0.6
    form_link_color = form_base_color.paint
    form_link_color.rgb.a = 0.9
    form_secondary_color.rgb.a = 0.6
    form_alternate_color.rgb.a = 0.6
    palette = {
      gradient_start: gradient_start,
      gradient_end: gradient_end,
      form_primary_color: form_primary_color,
      form_primary_text_color: form_primary_text_color,
      form_link_color: form_link_color,
      form_secondary_color: form_secondary_color,
      form_secondary_text_color: form_secondary_text_color,
      form_alternate_color: form_alternate_color,
      form_alternate_text_color: form_alternate_text_color
    }
  end

  # instrument_method
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

  # instrument_method
  def self.cache_object(name, id, id_attribute = 'id', json_params = nil)
    Rails.logger.debug "cache object #{name}, #{id_attribute}, #{id}".blue
    cache_candidate = Object.const_get(name.capitalize).find_by("#{id_attribute} = ?", id)
    key = "cached_#{name}_#{id}_#{cache_candidate.updated_at}"
    Rails.logger.debug "Redis key: #{key}".blue
    return cached = JSON.parse(REDIS.get(key), symbolize_names: true) if REDIS.exists(key)
    cached = cache_candidate.as_json(json_params) if cache_candidate
    res = cached.to_json if cached
    REDIS.setex(key, const_get("#{name.upcase}_LIFETIME"), res) if res
    Rails.logger.debug "cached data: #{cached.inspect}".blue
    cached&.symbolize_keys
  end

  # instrument_method
  def self.use(key:, lifetime: 15.minutes)
    return JSON.parse(REDIS.get(key), symbolize_names: true) if REDIS.exists(key)
    data = yield
    REDIS.setex(key, lifetime, data.to_json)
    data
  end

  # instrument_method
  def self.flush(object, id)
    key = "cached_#{object}_#{id}"
    REDIS.del(key) if REDIS.exists(key)
  end

  def self.flush_locations_list(user_id)
    key = "locations_list_#{user_id}"
    REDIS.del(key) if REDIS.exists(key)
  end
end
