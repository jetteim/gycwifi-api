require 'simplecov'
require 'pundit/matchers'
require 'rspec/core'

SimpleCov.start

RSpec.configure do |config|
  Dir['./spec/support/**/*.rb'].each { |f| require f }

  # config.include Requests::JsonHelper, type: :request
  # config.iurinclude Requests::RequestHelpers, type: :request
  config.include UriHelper # , type: request, :controller]
  config.include JsonHelper # , type: :request
  config.include SignInHelper # , type: :request

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation, except:
      [ActiveRecord::InternalMetadata.table_name]
  end

  config.before(:each) do
    REDIS.keys.each{ |key| REDIS.del(key)}
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
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
