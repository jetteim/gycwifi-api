module Oauth
  class TwitterLibrary
    TWITTER_KEY = ENV['TWITTER_KEY'] || 'fI1qz0H8qdBhk95AFVE1b1S3k'
    TWITTER_SECRET = ENV['TWITTER_SECRET'] || 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'

    def self.get_request_token(oauth_callback)
      res = JSON.parse(RestClient.post('https://api.twitter.com/oauth/request_token',
                                       oauth_callback: oauth_callback, oauth_consumer_key: TWITTER_KEY), symbolize_names: true)
      Rails.logger.debug "twitter request_token call returned #{res.inspect}".green
      res
    end

    def self.access_token(auth_data)
      Rails.logger.debug "twitter access_token params #{auth_data.inspect}".magenta
      res = JSON.parse(
        RestClient.post('https://api.twitter.com/oauth/access_token',
                        oauth_token: auth_data[:oauth_token],
                        oauth_verifier: auth_data[:oauth_verifier], oauth_consumer_key: TWITTER_KEY),
        symbolize_names: true
      )
      Rails.logger.debug "twitter access_token returned #{res.inspect}".green
      res
    end

    def self.user_data(oauth_token, oauth_verifier)
      # bearer_token_credentials = "#{ENV['TWITTER_KEY']}:#{ENV['TWITTER_SECRET']}"
      Rails.logger.debug "twitter auth - oauth_token: #{oauth_token}, oauth_verifier: #{oauth_verifier}".green
      # twitter_key = 'wrJz64NqtUnezFE2m86toABdV'
      # twitter_secret = '4bDGx7GXDi1ouCpudpVx2qmeaMCX4ZzkHuos9fvQdFk3b1Zw0Y'

      access_token
    end
  end
end
