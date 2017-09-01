
require 'oauth'

module Oauth
  class TwitterLibrary
    TWITTER_KEY = ENV['TWITTER_KEY'] || 'fI1qz0H8qdBhk95AFVE1b1S3k'
    TWITTER_SECRET = ENV['TWITTER_SECRET'] || 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'
    CONSUMER_CONFIG = {
      site: 'https://api.twitter.com',
      request_token_path: '/oauth/request_token',
      authorize_path: '/oauth/authorize',
      access_token_path: '/oauth/access_token'
    }.freeze

    @@consumer = OAuth::Consumer.new(TWITTER_KEY, TWITTER_SECRET, CONSUMER_CONFIG)

    def self.get_request_token(callback_url)
      @request_token = @@consumer.get_request_token(oauth_callback: callback_url)
      Rails.logger.debug "request_token: #{@request_token.inspect}".red
      REDIS.setex(redis_key, 15.minutes, @request_token.secret)
      # REDIS.setex("oauth_token_#{@request_token.token}_secret", 15.minutes, @request_token.secret)
      { oauth_token: @request_token.token, oauth_secret: @request_token.secret, oauth_callback_url: callback_url }
    end

    def self.user_data(oauth_token:, oauth_verifier:)
      Rails.logger.debug "request_token: #{@request_token.inspect}".red
      Rails.logger.debug "instance contains user data: #{@user_data.inspect}".green if @user_data
      redis_data = JSON.parse(REDIS.get(redis_user_data_key), symbolize_keys: true)
      Rails.logger.debug "REDIS stored data: #{redis_data.inspect}".green if redis_data
      return @user_data if @user_data
      return redis_data if redis_data
      options = { oauth_token: @request_token.token, oauth_token_secret: @request_token.secret, oauth_verifier: oauth_verifier }
      @request_token = OAuth::RequestToken.from_hash(@@consumer, options)
      access_token = @request_token.get_access_token(options)
      Rails.logger.debug "access token: #{access_token.inspect}".magenta
      # pull user info now
      account = JSON.parse(access_token.get('https://api.twitter.com/1.1/account/verify_credentials.json', include_email: 'true', skip_status: 'true').body)
      Rails.logger.debug "twitter account data: #{account.inspect}".green
      @user_data = {
        provider: 'twitter',
        uid: account['id'],
        username: account['name'] || account['id'],
        image: account['profile_image_url_https'],
        profile: "https://twitter.com/intent/user?user_id=#{account['id']}",
        location: account['location'],
        email: account['email']
      }
      REDIS.setex(redis_user_data_key, 1.minute, @user_data.to_json)
      @user_data
    end

    def self.redis_token_key(token = nil)
      token ||= @request_token.token
      "oauth_request_#{token}_secret"
    end

    def self.redis_user_data_key(token = nil)
      token ||= @request_token.token
      "oauth_request_#{token}_user"
    end
  end
end
