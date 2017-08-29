module Oauth
  class TwitterLibrary
    def self.request_token(params)
      twitter_key = 'fI1qz0H8qdBhk95AFVE1b1S3k'
      twitter_secret = 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'
      result = JSON.parse(RestClient::Request.execute(
                            method: :post,
                            url: 'https://api.twitter.com/oauth/request_token',
                            oauth_callback: params[:url],
                            user: twitter_key,
                            password: twitter_secret
      ))
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
