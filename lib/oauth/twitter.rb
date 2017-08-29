module Oauth
  class TwitterLibrary
    TWITTER_KEY = ENV['TWITTER_KEY'] || 'fI1qz0H8qdBhk95AFVE1b1S3k'
    TWITTER_SECRET = ENV['TWITTER_SECRET'] || 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'

    def self.request_token(oauth_callback)
      JSON.parse(RestClient.post('https://api.twitter.com/oauth/request_token',
                                 oauth_callback: oauth_callback))
    end

    def self.access_token(_auth_data)
      JSON.parse(RestClient::Request.execute(
                   method: :post,
                   url: 'https://api.twitter.com/oauth/request_token',
                   oauth_callback: params[:url],
                   user: twitter_key,
                   password: twitter_secret
      ), symbolize_names: true)
    end

    def self.user_data(access_code, redirect_url)
      # bearer_token_credentials = "#{ENV['TWITTER_KEY']}:#{ENV['TWITTER_SECRET']}"
      Rails.logger.debug "twitter auth, access code #{access_code}, redirect_url #{redirect_url}".green
      # twitter_key = 'wrJz64NqtUnezFE2m86toABdV'
      # twitter_secret = '4bDGx7GXDi1ouCpudpVx2qmeaMCX4ZzkHuos9fvQdFk3b1Zw0Y'
      token_request = JSON.parse(
        RestClient.post('https://api.twitter.com/oauth/access_token',
                        client_id: ENV['TWITTER_KEY'],
                        client_secret: ENV['TWITTER_SECRET'],
                        code: access_code,
                        redirect_uri: redirect_url), symbolize_names: true
      )
      Rails.logger.debug "got reply: #{token_request}".green
    end
  end
end
