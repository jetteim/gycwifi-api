module Oauth
  class FacebookLibrary
    def self.user_data(access_code:, redirect_url:)
      token_request = JSON.parse(
        RestClient.post(
          'https://graph.facebook.com/v2.8/oauth/access_token',
          client_id: ENV['FACEBOOK_KEY'],
          client_secret: ENV['FACEBOOK_SECRET'],
          code: access_code,
          redirect_uri: redirect_url
        ), symbolize_names: true
      )
      access_token = token_request[:access_token]
      user_data = RestClient.get(
        'https://graph.facebook.com/v2.8/me',
        params: {
          access_token: access_token,
          fields: 'id,gender,birthday,hometown,first_name,last_name,picture,email,location'
        },
        accept: :json
      )
      raw = JSON.parse(user_data, symbolize_names: true)
      begin
        if birthday = DateTime.parse(raw[:birthday])
          bdate_day = birthday.day
          bdate_month = birthday.month
          bdate_year = birthday.year
        end
      rescue
      end
      {
        provider: 'facebook',
        uid: raw[:id],
        username: "#{raw[:first_name] || ''} #{raw[:last_name] || ''}",
        image: raw.dig(:picture, :data, :url),
        profile: "https://facebook.com/#{raw[:id]}",
        gender: raw[:gender],
        bdate_day:   bdate_day,
        bdate_month: bdate_month,
        bdate_year:  bdate_year,
        location: raw.dig(:location, :name) || raw[:hometown],
        email: raw[:email]
      }
    end
  end
end
