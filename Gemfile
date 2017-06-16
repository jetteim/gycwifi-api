source 'https://rubygems.org'

# ruby '~> 2.3.1'

gem 'jbuilder', '~> 2.5'
gem 'rack-cors'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'rails-i18n', '~> 5.0.0' # For 5.0.x

group :staging, :production do
  gem 'daemons'
  gem 'delayed_job'
  gem 'delayed_job_active_record'
  gem 'rmagick'
  gem 'skylight'
  gem 'unicorn'
  # Servers
  # gem 'puma'
  # gem 'scout_apm'
  # gem 'meta_request'
  # gem 'rack-mini-profiler'
  # gem 'memory_profiler'
end

# Auth

gem 'google-api-client'
gem 'googleauth'
gem 'instagram'
gem 'jwt'
gem 'koala'
gem 'omniauth-instagram'
gem 'pundit'
gem 'twitter_oauth'

# gem 'omniauth-google-oauth2'
# gem 'oauth2'
# gem 'omniauth'
# gem 'omniauth-twitter'
# gem 'omniauth-google-oauth2'
# gem 'omniauth-googleplus'
# gem 'omniauth-facebook'
# gem 'omniauth-vkontakte'
# gem 'omniauth-odnoklassniki'
# gem 'omniauth-instagram'
# gem 'omniauth-github'
# gem 'omniauth-soundcloud'

#

# Data
gem 'active_model_serializers', '~> 0.8.3'
gem 'annotate'
gem 'bcrypt'
gem 'friendly_id'
gem 'mtik'
gem 'pg'
gem 'redis'
gem 'simple_enum'
gem 'sqlite3'
# gem 'high_voltage', '~> 3.0.0'
gem 'kaminari'
gem 'seed_dump'
# gem 'activerecord-session_store'
# gem 'mysql2', '~> 0.3.17'
# gem 'ar-octopus'
# gem 'redis-rails'

# Images
gem 'carrierwave'
gem 'mini_magick'

# Other gems
# gem 'turbolinks'
gem 'axlsx'
gem 'axlsx_rails'
gem 'babosa'
gem 'binding_of_caller'
gem 'bullet'
gem 'colored'
gem 'dotenv-rails'
gem 'lograge'
gem 'net-ssh'
gem 'pry-rails'
gem 'rack-attack'
gem 'rails_config'
gem 'responders'
gem 'rest-client'
gem 'rubyzip'
gem 'russian'
gem 'shog'
gem 'telegram-bot-ruby'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'zip-zip'

group :test do
  gem 'capybara'
  gem 'cucumber'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
  gem 'mocha'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :development, :test do
  # gem 'terminal-notifier-guard'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rspec'
  gem 'rspec-rails', '~> 3.5'
  gem 'faker'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'byebug', platform: :mri
end

group :development do
  # gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'
  gem 'bullet'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
