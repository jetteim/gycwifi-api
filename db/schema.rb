# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_170_815_102_903) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'agent_payment_methods', force: :cascade do |t|
    t.string   'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'agent_rewards', force: :cascade do |t|
    t.integer  'agent_id',                           null: false
    t.integer  'order_id',                           null: false
    t.datetime 'created_at',                         null: false
    t.datetime 'updated_at',                         null: false
    t.integer  'status_cd'
    t.decimal  'amount', precision: 9, scale: 2
    t.index ['agent_id'], name: 'index_agent_rewards_on_agent_id', using: :btree
    t.index ['order_id'], name: 'index_agent_rewards_on_order_id', using: :btree
  end

  create_table 'agents', force: :cascade do |t|
    t.integer  'user_id',                 null: false
    t.integer  'agent_payment_method_id'
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
    t.index ['agent_payment_method_id'], name: 'index_agents_on_agent_payment_method_id', using: :btree
    t.index ['user_id'], name: 'index_agents_on_user_id', using: :btree
  end

  create_table 'answers', force: :cascade do |t|
    t.string   'title'
    t.integer  'question_id'
    t.datetime 'created_at',                  null: false
    t.datetime 'updated_at',                  null: false
    t.boolean  'custom', default: false
    t.index ['question_id'], name: 'index_answers_on_question_id', using: :btree
  end

  create_table 'attempts', force: :cascade do |t|
    t.integer  'client_id'
    t.integer  'answer_id'
    t.datetime 'created_at',     null: false
    t.datetime 'updated_at',     null: false
    t.string   'custom_answer'
    t.integer  'interview_uuid'
    t.index ['answer_id'], name: 'index_attempts_on_answer_id', using: :btree
    t.index ['client_id'], name: 'index_attempts_on_client_id', using: :btree
  end

  create_table 'auth_logs', force: :cascade do |t|
    t.string   'username'
    t.string   'password'
    t.integer  'timeout'
    t.integer  'client_device_id'
    t.datetime 'created_at',       null: false
    t.datetime 'updated_at',       null: false
    t.integer  'voucher_id'
    t.index ['client_device_id'], name: 'index_auth_logs_on_cleint_device_id', using: :btree
    t.index ['password'], name: 'index_auth_logs_on_password', using: :btree
    t.index ['username'], name: 'index_auth_logs_on_username', using: :btree
    t.index ['voucher_id'], name: 'index_auth_logs_on_voucher_id', using: :btree
  end

  create_table 'bans', force: :cascade do |t|
    t.datetime 'until_date'
    t.integer  'location_id'
    t.integer  'client_id'
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
    t.index ['client_id'], name: 'index_bans_on_client_id', using: :btree
    t.index ['location_id'], name: 'index_bans_on_location_id', using: :btree
  end

  create_table 'brands', force: :cascade do |t|
    t.string   'title',                default: 'GYC Free WiFi', null: false
    t.string   'logo',                 default: '/images/logo.png'
    t.string   'bg_color',             default: '#0e1a35'
    t.string   'background',           default: '/images/default_background.png'
    t.string   'redirect_url',         default: 'https://gycwifi.com'
    t.integer  'auth_expiration_time', default: 3600,                             null: false
    t.integer  'category_id',                                                     null: false
    t.text     'promo_text', default: 'Sample promo text'
    t.string   'slug', null: false
    t.integer  'user_id'
    t.datetime 'created_at',                                                      null: false
    t.datetime 'updated_at',                                                      null: false
    t.boolean  'sms_auth'
    t.string   'template',             default: 'default'
    t.boolean  'public',               default: false
    t.integer  'layout_id',            default: 1
    t.index ['layout_id'], name: 'index_brands_on_layout_id', using: :btree
    t.index ['slug'], name: 'index_brands_on_slug', using: :btree
    t.index ['user_id'], name: 'index_brands_on_user_id', using: :btree
  end

  create_table 'categories', force: :cascade do |t|
    t.string   'title_en'
    t.string   'title_ru'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'client_accounting_logs', force: :cascade do |t|
    t.datetime 'created_at',           default: -> { 'now()' }, null: false
    t.datetime 'updated_at',           default: -> { 'now()' }, null: false
    t.string   'acctsessionid'
    t.string   'acctuniqueid'
    t.string   'username'
    t.string   'groupname'
    t.string   'realm'
    t.string   'nasipaddress'
    t.string   'nasportid'
    t.string   'nasporttype'
    t.datetime 'acctstarttime'
    t.datetime 'acctstoptime'
    t.bigint   'acctsessiontime'
    t.string   'acctauthentic'
    t.string   'connectinfo_start'
    t.string   'connectinfo_stop'
    t.bigint   'acctinputoctets'
    t.bigint   'acctoutputoctets'
    t.string   'calledstationid'
    t.string   'callingstationid'
    t.string   'acctterminatecause'
    t.string   'servicetype'
    t.string   'xascendsessionsvrkey'
    t.string   'framedprotocol'
    t.string   'framedipaddress'
    t.integer  'acctstartdelay'
    t.integer  'acctstopdelay'
    t.index ['acctstarttime'], name: 'index_client_accounting_logs_on_acctstarttime', using: :btree
    t.index ['acctstoptime'], name: 'index_client_accounting_logs_on_acctstoptime', using: :btree
    t.index ['calledstationid'], name: 'index_client_accounting_logs_on_calledstationid', using: :btree
    t.index ['created_at'], name: 'index_client_accounting_logs_on_created_at', using: :btree
    t.index ['nasipaddress'], name: 'index_client_accounting_logs_on_nasipaddress', using: :btree
    t.index ['nasportid'], name: 'index_client_accounting_logs_on_nasportid', using: :btree
    t.index ['updated_at'], name: 'index_client_accounting_logs_on_updated_at', using: :btree
    t.index ['username'], name: 'index_client_accounting_logs_on_username', using: :btree
  end

  create_table 'client_counters', force: :cascade do |t|
    t.integer  'client_id'
    t.integer  'location_id'
    t.integer  'counter'
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
    t.index ['client_id'], name: 'index_client_counters_on_client_id', using: :btree
    t.index ['created_at'], name: 'index_client_counters_on_created_at', using: :btree
    t.index ['location_id'], name: 'index_client_counters_on_location_id', using: :btree
    t.index ['updated_at'], name: 'index_client_counters_on_updated_at', using: :btree
  end

  create_table 'client_devices', force: :cascade do |t|
    t.string   'mac'
    t.string   'platform_os'
    t.string   'platform_product'
    t.integer  'client_id'
    t.datetime 'created_at',       null: false
    t.datetime 'updated_at',       null: false
    t.index ['client_id'], name: 'index_client_devices_on_client_id', using: :btree
    t.index ['created_at'], name: 'index_client_devices_on_created_at', using: :btree
    t.index ['mac'], name: 'index_client_devices_on_mac', using: :btree
    t.index ['updated_at'], name: 'index_client_devices_on_updated_at', using: :btree
  end

  create_table 'clients', force: :cascade do |t|
    t.string   'phone_number'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
    t.index ['created_at'], name: 'index_clients_on_created_at', using: :btree
    t.index ['phone_number'], name: 'index_clients_on_phone_number', unique: true, using: :btree
    t.index ['updated_at'], name: 'index_clients_on_updated_at', using: :btree
  end

  create_table 'delayed_jobs', force: :cascade do |t|
    t.integer  'priority',   default: 0, null: false
    t.integer  'attempts',   default: 0, null: false
    t.text     'handler',                null: false
    t.text     'last_error'
    t.datetime 'run_at'
    t.datetime 'locked_at'
    t.datetime 'failed_at'
    t.string   'locked_by'
    t.string   'queue'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index %w[priority run_at], name: 'delayed_jobs_priority', using: :btree
    t.index ['queue'], name: 'delayed_jobs_queue', using: :btree
  end

  create_table 'device_auth_pendings', id: :integer, default: -> { "nextval('device_auth_pending_id_seq'::regclass)" }, force: :cascade do |t|
    t.string   'mac'
    t.string   'phone'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string   'sms_code'
    t.index ['mac'], name: 'index_device_auth_pending_on_mac', using: :btree
    t.index ['phone'], name: 'index_device_auth_pending_on_phone', using: :btree
  end

  create_table 'friendly_id_slugs', force: :cascade do |t|
    t.string   'slug',                      null: false
    t.integer  'sluggable_id',              null: false
    t.string   'sluggable_type', limit: 50
    t.string   'scope'
    t.datetime 'created_at'
    t.index %w[slug sluggable_type scope], name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope', unique: true, using: :btree
    t.index %w[slug sluggable_type], name: 'index_friendly_id_slugs_on_slug_and_sluggable_type', using: :btree
    t.index ['sluggable_id'], name: 'index_friendly_id_slugs_on_sluggable_id', using: :btree
    t.index ['sluggable_type'], name: 'index_friendly_id_slugs_on_sluggable_type', using: :btree
  end

  create_table 'layouts', force: :cascade do |t|
    t.string   'title'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string   'local_path'
  end

  create_table 'locations', force: :cascade do |t|
    t.string   'title', null: false
    t.string   'phone'
    t.string   'address'
    t.string   'url', default: 'https://gycwifi.com'
    t.string   'ssid', null: false
    t.string   'staff_ssid'
    t.string   'staff_ssid_pass'
    t.string   'redirect_url',         default: 'https://gycwifi.com',                 null: false
    t.string   'wlan',                 default: '1M',                                  null: false
    t.string   'wan',                  default: '5M',                                  null: false
    t.integer  'auth_expiration_time', default: 3600,                                  null: false
    t.text     'promo_text',           default: "\xD0\xA1\xD0\xBF\xD0\xB0\xD1\x81\xD0\xB8\xD0\xB1\xD0\xBE \xD0\xB7\xD0\xB0 \xD1\x82\xD0\xBE, \xD1\x87\xD1\x82\xD0\xBE \xD0\xB7\xD0\xB0\xD0\xB3\xD0\xBB\xD1\x8F\xD0\xBD\xD1\x83\xD0\xBB\xD0\xB8 \xD0\xBA \xD0\xBD\xD0\xB0\xD0\xBC!", null: false
    t.string   'logo',                 default: '/images/logo.png'
    t.string   'bg_color',             default: '#0e1a35'
    t.string   'background',           default: '/images/default_background.png'
    t.boolean  'password',             default: false,                                 null: false
    t.boolean  'twitter',              default: false,                                 null: false
    t.boolean  'google',               default: false,                                 null: false
    t.boolean  'vk',                   default: false,                                 null: false
    t.boolean  'insta',                default: false,                                 null: false
    t.boolean  'facebook',             default: false,                                 null: false
    t.string   'slug',                                                                 null: false
    t.integer  'brand_id',                                                             null: false
    t.integer  'category_id', default: 24, null: false
    t.integer  'user_id',                                                              null: false
    t.datetime 'created_at',                                                           null: false
    t.datetime 'updated_at',                                                           null: false
    t.integer  'poll_id'
    t.string   'promo_type',           default: 'text'
    t.string   'last_page_content',    default: 'text', null: false
    t.boolean  'sms_auth'
    t.integer  'sms_count'
    t.boolean  'voucher', default: true
    t.index ['brand_id'], name: 'index_locations_on_brand_id', using: :btree
    t.index ['category_id'], name: 'index_locations_on_category_id', using: :btree
    t.index ['created_at'], name: 'index_locations_on_created_at', using: :btree
    t.index ['updated_at'], name: 'index_locations_on_updated_at', using: :btree
    t.index ['user_id'], name: 'index_locations_on_user_id', using: :btree
  end

  create_table 'notifications', force: :cascade do |t|
    t.datetime 'sent_at'
    t.integer  'router_id'
    t.datetime 'created_at',                    null: false
    t.datetime 'updated_at',                    null: false
    t.integer  'user_id'
    t.integer  'location_id'
    t.integer  'poll_id'
    t.string   'title'
    t.string   'details'
    t.boolean  'seen', default: false
    t.datetime 'tour_last_run'
    t.boolean  'silence',       default: false
    t.boolean  'favorite',      default: false
    t.index ['location_id'], name: 'index_notifications_on_location_id', using: :btree
    t.index ['poll_id'], name: 'index_notifications_on_poll_id', using: :btree
    t.index ['router_id'], name: 'index_notifications_on_router_id', using: :btree
    t.index ['sent_at'], name: 'index_notifications_on_sent_at', using: :btree
    t.index ['user_id'], name: 'index_notifications_on_user_id', using: :btree
  end

  create_table 'opinions', force: :cascade do |t|
    t.string   'style'
    t.text     'message'
    t.string   'location'
    t.integer  'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_opinions_on_user_id', using: :btree
  end

  create_table 'order_products', force: :cascade do |t|
    t.integer  'order_id',                           null: false
    t.integer  'product_id',                         null: false
    t.decimal  'price', precision: 8, scale: 2, null: false
    t.datetime 'created_at',                         null: false
    t.datetime 'updated_at',                         null: false
    t.index ['order_id'], name: 'index_order_products_on_order_id', using: :btree
    t.index ['product_id'], name: 'index_order_products_on_product_id', using: :btree
  end

  create_table 'order_statuses', force: :cascade do |t|
    t.integer  'code_cd',    null: false
    t.integer  'order_id',   null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['order_id'], name: 'index_order_statuses_on_order_id', using: :btree
  end

  create_table 'orders', force: :cascade do |t|
    t.integer  'user_id',    null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_orders_on_user_id', using: :btree
  end

  create_table 'pages', force: :cascade do |t|
    t.string   'title'
    t.text     'content'
    t.string   'category'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'polls', force: :cascade do |t|
    t.string   'title'
    t.integer  'user_id'
    t.datetime 'created_at',                null: false
    t.datetime 'updated_at',                null: false
    t.boolean  'run_once', default: true
    t.index ['user_id'], name: 'index_polls_on_user_id', using: :btree
  end

  create_table 'post_auth_logs', force: :cascade do |t|
    t.string   'username'
    t.string   'passsword'
    t.string   'reply'
    t.string   'calledstationid'
    t.string   'callingstationid'
    t.datetime 'created_at',       null: false
    t.datetime 'updated_at',       null: false
    t.index ['callingstationid'], name: 'index_post_auth_logs_on_callingstationid', using: :btree
    t.index ['created_at'], name: 'index_post_auth_logs_on_created_at', using: :btree
    t.index ['updated_at'], name: 'index_post_auth_logs_on_updated_at', using: :btree
    t.index ['username'], name: 'index_post_auth_logs_on_username', using: :btree
  end

  create_table 'products', force: :cascade do |t|
    t.string   'name'
    t.text     'description'
    t.decimal  'price', precision: 9, scale: 2
    t.string   'type'
    t.datetime 'created_at',                          null: false
    t.datetime 'updated_at',                          null: false
  end

  create_table 'promo_codes', force: :cascade do |t|
    t.string   'code',       null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer  'agent_id'
  end

  create_table 'questions', force: :cascade do |t|
    t.string   'title'
    t.string   'question_type'
    t.integer  'poll_id'
    t.datetime 'created_at',    null: false
    t.datetime 'updated_at',    null: false
    t.index ['poll_id'], name: 'index_questions_on_poll_id', using: :btree
  end

  create_table 'routers', force: :cascade do |t|
    t.string   'serial'
    t.string   'comment'
    t.string   'first_dns_server',       default: '8.8.8.8'
    t.string   'second_dns_server',      default: '8.8.4.4'
    t.string   'common_name'
    t.string   'ip_name'
    t.string   'router_local_ip',        default: '192.168.88.1'
    t.boolean  'disable_service_access', default: true
    t.boolean  'split_networks',         default: true
    t.boolean  'isolate_wlan',           default: true
    t.boolean  'block_service_ports',    default: true
    t.string   'admin_ethernet_port',    default: 'ether5'
    t.string   'router_admin_ip',        default: '192.168.10.1'
    t.string   'admin_password',         default: 'admin'
    t.string   'radius_secret'
    t.text     'ssl_certificate'
    t.text     'ssl_key'
    t.string   'radius_db_nas_id'
    t.boolean  'status'
    t.integer  'location_id'
    t.integer  'user_id'
    t.datetime 'created_at',                                      null: false
    t.datetime 'updated_at',                                      null: false
    t.string   'config_type'
    t.string   'hotspot_interface'
    t.string   'hotspot_address'
    t.index ['common_name'], name: 'index_routers_on_common_name', using: :btree
    t.index ['created_at'], name: 'index_routers_on_created_at', using: :btree
    t.index ['ip_name'], name: 'index_routers_on_ip_name', using: :btree
    t.index ['location_id'], name: 'index_routers_on_location_id', using: :btree
    t.index ['serial'], name: 'index_routers_on_serial', using: :btree
    t.index ['updated_at'], name: 'index_routers_on_updated_at', using: :btree
    t.index ['user_id'], name: 'index_routers_on_user_id', using: :btree
  end

  create_table 'sessions', force: :cascade do |t|
    t.string   'session_id', null: false
    t.text     'data'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['session_id'], name: 'index_sessions_on_session_id', unique: true, using: :btree
    t.index ['updated_at'], name: 'index_sessions_on_updated_at', using: :btree
  end

  create_table 'sms_logs', force: :cascade do |t|
    t.string   'sms_code'
    t.datetime 'sent_at'
    t.integer  'status_cd'
    t.integer  'client_device_id'
    t.datetime 'created_at',       null: false
    t.datetime 'updated_at',       null: false
    t.integer  'location_id'
    t.index ['client_device_id'], name: 'index_sms_logs_on_client_device_id', using: :btree
    t.index ['sent_at'], name: 'index_sms_logs_on_sent_at', using: :btree
    t.index ['status_cd'], name: 'index_sms_logs_on_status_cd', using: :btree
  end

  # Could not dump table "social_accounts" because of following StandardError
  #   Unknown type 'social_provider' for column 'provider'

  create_table 'social_logs', force: :cascade do |t|
    t.integer  'social_account_id'
    t.string   'provider'
    t.integer  'location_id'
    t.integer  'router_id'
    t.datetime 'created_at',        null: false
    t.datetime 'updated_at',        null: false
    t.index ['created_at'], name: 'index_social_logs_on_created_at', using: :btree
    t.index ['location_id'], name: 'index_social_logs_on_location_id', using: :btree
    t.index ['provider'], name: 'index_social_logs_on_provider', using: :btree
    t.index ['router_id'], name: 'index_social_logs_on_router_id', using: :btree
    t.index ['updated_at'], name: 'index_social_logs_on_updated_at', using: :btree
  end

  create_table 'users', force: :cascade do |t|
    t.string   'username',                                              null: false
    t.string   'email',                                                 null: false
    t.string   'password',                                              null: false
    t.string   'avatar',        default: '/images/avatars/default.jpg'
    t.string   'type',          default: 'FreeUser',                    null: false
    t.boolean  'tour',          default: true,                          null: false
    t.datetime 'created_at',                                            null: false
    t.datetime 'updated_at',                                            null: false
    t.string   'lang', default: 'ru'
    t.integer  'sms_count'
    t.integer  'user_id',       default: 274
    t.datetime 'expiration',    default: '2017-06-05 06:29:47'
    t.integer  'promo_code_id'
    t.index ['email'], name: 'index_users_on_email', using: :btree
    t.index ['type'], name: 'index_users_on_type', using: :btree
    t.index %w[username email], name: 'index_users_on_username_and_email', unique: true, using: :btree
  end

  create_table 'vips', force: :cascade do |t|
    t.string   'phone'
    t.integer  'location_id'
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
    t.index ['location_id'], name: 'index_vips_on_location_id', using: :btree
  end

  create_table 'vouchers', force: :cascade do |t|
    t.integer  'location_id'
    t.string   'password'
    t.datetime 'expiration'
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
    t.integer  'client_id'
    t.integer  'duration', default: 0
    t.index ['client_id'], name: 'index_vouchers_on_client_id', using: :btree
    t.index ['location_id'], name: 'index_vouchers_on_location_id', using: :btree
    t.index ['password'], name: 'index_vouchers_on_password', using: :btree
  end

  add_foreign_key 'agent_rewards', 'agents'
  add_foreign_key 'agent_rewards', 'orders'
  add_foreign_key 'agents', 'agent_payment_methods'
  add_foreign_key 'agents', 'users'
  add_foreign_key 'order_products', 'orders'
  add_foreign_key 'order_products', 'products'
  add_foreign_key 'order_statuses', 'orders'
  add_foreign_key 'orders', 'users'
end
