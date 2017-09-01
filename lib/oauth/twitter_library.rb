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
      REDIS.setex(redis_token_key, 15.minutes, @request_token.secret)
      # REDIS.setex("oauth_token_#{@request_token.token}_secret", 15.minutes, @request_token.secret)
      { oauth_token: @request_token.token, oauth_secret: @request_token.secret, oauth_callback_url: callback_url }
    end

    def self.user_data(oauth_token:, oauth_verifier:, oauth_secret: nil)
      Rails.logger.debug "instance contains user data: #{@user_data.inspect}".green if @user_data
      return @user_data if @user_data
      Rails.logger.debug "request_token: #{@request_token.inspect}".yellow if @request_token
      token = @request_token&.token || oauth_token

      Rails.logger.debug "REDIS stored user data: #{redis_data.inspect}".green if redis_data = REDIS.get(redis_user_data_key(token))
      return JSON.parse(redis_data, symbolize_keys: true) if redis_data

      Rails.logger.debug "REDIS stored secret: #{redis_secret = REDIS.get(redis_token_key(token))}".green
      secret = @request_token&.secret || oauth_secret || redis_secret

      options = { oauth_token: token, oauth_token_secret: secret,  oauth_verifier: oauth_verifier }

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
      REDIS.setex(redis_user_data_key(@request_token.token), 15.minutes, @user_data.to_json)
      @user_data
    end

    def self.redis_token_key(token = nil)
      token ||= @request_token&.token
      "oauth_request_#{token}_secret"
    end

    def self.redis_user_data_key(token)
      "oauth_request_#{token}_user"
    end
  end
end
