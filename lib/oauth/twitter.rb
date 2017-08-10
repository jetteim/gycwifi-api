module Oauth
  class TwitterLibrary
    def self.request_token(params)
      twitter_key = 'wrJz64NqtUnezFE2m86toABdV'
      twitter_secret = '4bDGx7GXDi1ouCpudpVx2qmeaMCX4ZzkHuos9fvQdFk3b1Zw0Y'
      result = JSON.parse(RestClient::Request.execute(
                            method: :post,
                            url: 'https://api.twitter.com/oauth/request_token',
                            oauth_callback: params[:url],
                            user: twitter_key,
                            password: twitter_secret
      ))
    end

    def self.user_data(_access_code, _redirect_url)
      # bearer_token_credentials = "#{ENV['TWITTER_KEY']}:#{ENV['TWITTER_SECRET']}"
      twitter_key = 'wrJz64NqtUnezFE2m86toABdV'
      twitter_secret = '4bDGx7GXDi1ouCpudpVx2qmeaMCX4ZzkHuos9fvQdFk3b1Zw0Y'
      access_token = JSON.parse(RestClient::Request.execute(
                                  method: :post,
                                  url: 'https://api.twitter.com/oauth/access_token',
                                  oauth_token: params['oauth_token'],
                                  oauth_token_secret: params['oauth_token_secret'],
                                  user: twitter_key,
                                  password: twitter_secret
      ))
      auth_result = RestClient::Request.execute(
        method: :get,
        url: 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true',
        headers: { 'Authorization': "Bearer #{result['access_token']}" }
      )
      JSON.parse(auth_result).deep_symbolize_keys
    end
  end
end
