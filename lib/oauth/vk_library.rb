module Oauth
  class VkLibrary
    def self.user_data(access_code, redirect_url)
      # service_token = ENV['VK_SERVICE_TOKEN'] # '2c9153d82c9153d82c503b32f72cc5262722c912c9153d874364065842216d690d4fcd1'
      result = JSON.parse(
        RestClient.post(
          'https://oauth.vk.com/access_token',
          { client_id: ENV['VK_KEY'],
            client_secret: ENV['VK_SECRET'],
            code: access_code,
            redirect_uri: redirect_url },
          accept: :json
        ), symbolize_names: true
      )
      access_token = result[:access_token]
      auth_result  = RestClient.get(
        'https://api.vk.com/method/users.get',
        params: {
          access_token: access_token,
          fields: 'photo_id, verified, sex, bdate, city, country, home_town, has_photo, photo_50, photo_100, photo_200_orig, photo_200, photo_400_orig, photo_max, photo_max_orig, online, lists, domain, has_mobile, contacts, site, education, universities, schools, status, last_seen, followers_count, common_count, occupation, nickname, relatives, relation, personal, connections, exports, wall_comments, activities, interests, music, movies, tv, books, games, about, quotes, can_post, can_see_all_posts, can_see_audio, can_write_private_message, can_send_friend_request, is_favorite, is_hidden_from_feed, timezone, screen_name, maiden_name, crop_photo, is_friend, friend_status, career, military, blacklisted, blacklisted_by_me'
        },
        accept: :json
      )
      response = JSON.parse(auth_result, symbolize_names: true)
      raw = response.dig(:response, 0)
      begin
        if birthday = DateTime.strptime(raw[:bdate], '%d.%m.%Y')
          bdate_day = birthday.day
          bdate_month = birthday.month
          bdate_year = birthday.year
        end
      rescue
      end
      {
        provider: 'vk',
        uid: raw[:uid],
        username: "#{raw[:first_name] || ''} #{raw[:last_name] || ''}",
        image: raw[:photo_max_orig],
        profile: "https://vk.com/#{raw[:domain]}",
        gender: vk_gender(raw[:sex]),
        bdate_day:   bdate_day,
        bdate_month: bdate_month,
        bdate_year:  bdate_year,
        location: "#{raw[:city] || ''}, '#{raw[:country] || ''}"
      }
    end

    def self.vk_gender(sex)
      if sex == '2'
        'male'
      elsif sex == '1'
        'female'
      end
    end
  end
end
