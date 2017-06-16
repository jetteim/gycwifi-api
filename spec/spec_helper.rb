require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  Dir['./spec/support/**/*.rb'].each { |f| require f }

  # config.include Requests::JsonHelper, type: :request
  # config.iurinclude Requests::RequestHelpers, type: :request
  config.include UriHelper #, type: request, :controller]
  config.include JsonHelper#, type: :request
  config.include SignInHelper#, type: :request

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
    REDIS.keys.each{ |key| REDIS.del(key)}
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/uploads"]) if File.directory?("#{Rails.root}/spec/uploads")
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
