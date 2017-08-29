require 'addressable/uri'
require 'base64'
require 'openssl'

module Oauth
  class TwitterLibrary
    TWITTER_KEY = ENV['TWITTER_KEY'] || 'fI1qz0H8qdBhk95AFVE1b1S3k'
    TWITTER_SECRET = ENV['TWITTER_SECRET'] || 'ZLeoiweNZgw26pXXstC4qGbjAUD5NEb2aYYfDMWcwHQ5ILMHMN'
    OAUTH_SIGNATURE_METHOD = 'HMAC-SHA1'.freeze

    def self.get_request_token(url)
      params = {
        oauth_callback: url,
        oauth_consumer_key: TWITTER_KEY,
        oauth_signature_method: OAUTH_SIGNATURE_METHOD
      }
      res = JSON.parse(
        RestClient.post(
          'https://api.twitter.com/oauth/request_token',
          oauth_signature: oauth_signature('POST', 'https://api.twitter.com/oauth/request_token', params),
          params
        ), symbolize_names: true
      )
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

    def signature_base(method, url, params)
      # POST&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521
      query = Addressable::URI.new
      query.query_values = params
      "#{method.upcase}&#{Addressable::URI.encode(url)}&#{Addressable::URI.encode(query.query)}"
    end

    def signing_key(token_secret = nil)
      token_secret ? "#{Addressable::URI.encode(TWITTER_SECRET)}&#{Addressable::URI.encode(token_secret)}" : "#{Addressable::URI.encode(TWITTER_SECRET)}&"
    end

    def oauth_signature(method, url, params)
      Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, signing_key, signature_base(method, url, params))).chomp.delete("\n")
    end
  end
end
