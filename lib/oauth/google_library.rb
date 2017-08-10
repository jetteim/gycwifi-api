require 'googleauth'

module Oauth
  class GoogleLibrary
    def self.user_data(access_code, redirect_url)
      token = client.auth_code.get_token(access_code, redirect_uri: redirect_url)
      response = token.get 'https://www.googleapis.com/oauth2/v1/userinfo?alt=json'
      Rails.logger.debug "google raw response: #{response.inspect}".red.bold
      raw = JSON.parse(response.body, symbolize_names: true)
      {
        provider: 'google_oauth2',
        uid: raw[:id],
        image: raw[:picture],
        username: raw[:name],
        email: raw[:email],
        profile: raw[:link],
        gender: raw[:gender]
      }
    end

    def self.client
      @client ||= OAuth2::Client.new(
        ENV['GOOGLE_KEY'],
        ENV['GOOGLE_SECRET'],
        site: 'https://accounts.google.com',
        token_url: '/o/oauth2/token',
        authorize_url: '/o/oauth2/auth'
      )
    end
  end
end
