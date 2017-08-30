# == Schema Information
#
# Table name: social_accounts
#
#  id          :integer          not null, primary key
#  provider    :enum
#  uid         :string
#  vaucher     :string
#  username    :string
#  image       :string
#  profile     :string
#  email       :string
#  gender      :string
#  location    :string
#  bdate_day   :integer
#  bdate_month :integer
#  bdate_year  :integer
#  client_id   :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SocialAccount < ApplicationRecord
  # include Skylight::Helpers
  # Relations
  belongs_to :client, dependent: :destroy
  belongs_to :user
  has_many   :social_logs

  # enum provider: %i[
  #   password google_oauth2 vk facebook twitter instagram odnoklassniki
  # ]

  scope :with_emails, -> { where.not(email: nil) }

  # instrument_method
  def attributes
    super
  end

  def birthday
    DateTime.new(bdate_year, bdate_month, bdate_day) if bdate_year && bdate_month && bdate_day
  end

  # instrument_method
  def self.pull_user_data(auth_data)
    case auth_data[:provider]
    when 'instagram'
      user_data = Oauth::InstagramLibrary.user_data(access_code: auth_data[:access_code], redirect_url: auth_data[:redirect_url])
    when 'twitter'
      user_data = Oauth::TwitterLibrary.user_data(oauth_token: auth_data[:oauth_token], oauth_verifier: auth_data[:oauth_verifier])
    when 'vk'
      user_data = Oauth::VkLibrary.user_data(access_code: auth_data[:access_code], redirect_url: auth_data[:redirect_url])
    when 'google_oauth2'
      user_data = Oauth::GoogleLibrary.user_data(access_code: auth_data[:access_code], redirect_url: auth_data[:redirect_url])
    when 'facebook'
      user_data = Oauth::FacebookLibrary.user_data(access_code: auth_data[:access_code], redirect_url: auth_data[:redirect_url])
    end
    logger.info "вытащили данные из профиля соцсети: #{user_data}".cyan
    user_data
  end

  # instrument_method
  def self.find_social_account(user_data)
    social_account = where(provider: user_data[:provider], uid: user_data[:uid]).first_or_create
    social_account.username = user_data[:username]
    social_account.image = user_data[:image]
    social_account.profile = user_data[:profile]
    social_account.email = user_data[:email]
    social_account.gender = user_data[:gender]
    social_account.location = user_data[:location]
    social_account.bdate_day = user_data[:bdate_day]
    social_account.bdate_month = user_data[:bdate_month]
    social_account.bdate_year = user_data[:bdate_year]
    social_account if social_account.save
  end

  # instrument_method
  def linked_user
    return user if user
    username = self.username
    email = self.email || "#{provider}@#{provider}"
    unless user = User.find_by(username: username, email: email)
      user = User.create(
        username: username,
        password: SecureRandom.hex(6),
        email: email,
        avatar: image
      )
      update(user_id: user.id)
    end
    user
  end
end
