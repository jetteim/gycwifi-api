require 'oauth'

module Oauth
  class TwitterLibrary
    TWITTER_KEY = ENV['TWITTER_KEY'] || 'fI1qz0H8qdBhk95AFVE1b1S3k'
    TWITTER_SECRET = ENV['TWITTER_SECRET'] || 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'

    CONSUMER_CONFIG = {
      site: 'https://api.twitter.com',
      request_token_path: '/oauth/request_token',
      authorize_path: '/oauth/authorize',
      access_token_path: 'oauth/access_token'
    }.freeze

    def self.get_request_token(callback_url)
      @consumer = OAuth::Consumer.new(TWITTER_KEY, TWITTER_SECRET, CONSUMER_CONFIG)
      Rails.logger.debug "Oauth consumer: #{@consumer.inspect}".magenta
      @request_token = @consumer.get_request_token(oauth_callback: callback_url)
      Rails.logger.debug "request_token: #{@request_token.inspect}".magenta
      REDIS.setex("oauth_token_#{@request_token.token}_secret", 15.minutes, @request_token.secret)
      { oauth_token: @request_token.token, oauth_secret: @request_token.secret, oauth_callback_url: callback_url }
    end

    def self.user_data(oauth_token:, oauth_verifier:)
      Rails.logger.debug "request token: #{@request_token.inspect}".cyan
      Rails.logger.debug "consumer is #{@consumer.inspect}".red
      #@consumer ||= OAuth::Consumer.new(TWITTER_KEY, TWITTER_SECRET, CONSUMER_CONFIG)
      oauth_secret = REDIS.get("oauth_token_#{oauth_token}_secret") if REDIS.exists("oauth_token_#{oauth_token}_secret")
      OAuth::RequestToken.from_hash(@consumer, oauth_secret: oauth_secret, oauth_token: oauth_token, oauth_verifier: oauth_verifier)
      #Rails.logger.debug "new request token: #{@request_token.inspect}".yellow
      @access_token = @request_token.get_access_token
      Rails.logger.debug "access token: #{@access_token.inspect}".green
      # pull user info now
      account = @access_token.get('/account/verify_credentials.json', include_email: 'true',skip_status: 'true')
      Rails.logger.debug "twitter ccount data: #{account.inspect}"
      {
        provider: 'twitter',
        uid: account['id'],
        username: account['name'] || account['id'],
        image: account['profile_image_url_https'],
        profile: "https://twitter.com/intent/user?user_id=#{account['id']}",
        location: account['location'],
        email: account['email']
      }
    end
  end
end
