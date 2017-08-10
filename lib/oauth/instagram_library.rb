require 'instagram'

module Oauth
  class InstagramLibrary
    def self.user_data(access_code, redirect_url)
      raw = Instagram.get_access_token(access_code, redirect_uri: redirect_url)
      {
        provider: 'instagram',
        uid: raw.user.id,
        username: raw.user.username,
        image: raw.user.profile_picture,
        profile: "https://www.instagram.com/#{raw.user.username}"
      }
    end
  end
end
