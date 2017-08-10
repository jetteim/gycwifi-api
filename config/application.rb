require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'skylight'
require_relative 'initializers/log_before_timeout'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WifiManagement
  class Application < Rails::Application
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.middleware.use LogBeforeTimeout
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    # config.active_job.queue_adapter = :delayed_job
    # Generators config
    config.generators do |g|
      g.test_framework :rspec
      g.assets false
    end

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('app/workers')
    # config.autoload_paths << "#{Rails.root}/lib"

    # CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: :any
      end
    end

    config.active_record.schema_format = :sql
    config.skylight.environments = %w[production]
    config.skylight.probes += %w[active_model_serializers httpclient sequel action_controller redis action_view sequel]
  end
end
