require 'oauth'

module Oauth
  class TwitterLibrary
    TWITTER_KEY = ENV['TWITTER_KEY'] || 'fI1qz0H8qdBhk95AFVE1b1S3k'
    TWITTER_SECRET = ENV['TWITTER_SECRET'] || 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'

    CONSUMER_CONFIG = {
      site: 'https://api.twitter.com',
      request_token_path: '/oauth/request_token',
      # authorize_path: '/oauth/authorize',
      authorize_path: '/oauth/authenticate',
      access_token_path: 'oauth/access_token'
    }.freeze

    def self.get_request_token(callback_url)
      @consumer = OAuth::Consumer.new(TWITTER_KEY, TWITTER_SECRET, CONSUMER_CONFIG)
      Rails.logger.debug "Oauth consumer: #{@consumer.inspect}".magenta
      @request_token = @consumer.get_request_token(oauth_callback: callback_url)
      Rails.logger.debug "request_token: #{@request_token.inspect}".magenta
      @request_token
    end

    def self.user_data(auth_data)
      Rails.logger.debug "twitter auth params #{auth_data.inspect}".magenta
      @consumer ||= OAuth::Consumer.new(TWITTER_KEY, TWITTER_SECRET, CONSUMER_CONFIG)
      @request_token = OAuth::RequestToken.from_hash(@consumer, auth_data)
      @access_token = @request_token.get_access_token
      # pull user info now
    end
  end
end
