# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  username      :string           not null
#  email         :string           not null
#  password      :string           not null
#  avatar        :string           default("/images/avatars/default.jpg")
#  type          :string           default("FreeUser"), not null
#  tour          :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  lang          :string           default("ru")
#  sms_count     :integer          default(50)
#  user_id       :integer          default(274)
#  expiration    :datetime         default(Tue, 13 Jun 2017 19:24:21 UTC +00:00)
#  promo_code_id :integer
#

class User < ApplicationRecord #:nodoc:
  # Relations
  has_many :brands
  has_many :locations
  has_many :routers
  has_many :vouchers, through: :locations
  has_many :social_logs, through: :locations
  has_many :traffic_report, through: :routers
  has_many :traffic_data, through: :routers
  has_many :notifications
  has_many :polls
  has_many :questions, through: :polls
  has_many :answers, through: :questions
  has_many :attempts, through: :answers
  has_many :abilities
  has_many :social_accounts
  has_many :opinions
  has_many :orders, dependent: :destroy
  has_many :email_templates, dependent: :destroy
  has_many :sms_templates, dependent: :destroy
  has_many :users
  has_one :agent, dependent: :destroy
  belongs_to :user

  belongs_to :promo_code

  # Validations
  # validates :username, :email, :password, :role_cd, :tour, presence: true
  validates :username, length: { maximum: 100 }
  # validates :email, length: { maximum: 100 }
  # validates :password, length: { minimum: 5, maximum: 100 }

  # Uploaders
  # mount_uploader :avatar, AvatarUploader

  include UserRoles

  def owner
    user
  end

  def peers
    owner&.users || []
  end

  def agent_id
    agent&.id
  end

  def profile
    {
      id: id,
      auth: true,
      username: username,
      email: email,
      avatar: avatar,
      token: token,
      role: role,
      user_info: front_model
    }
  end

  def token
    logger.debug "building token for user #{id}".cyan
    token = Token.encode(id)
    REDIS.sadd(redis_token_key, token)
    token
  end

  def redis_token_key
    "token_#{id}"
  end

  def front_model
    {
      id: id,
      role: role,
      permissions: front_permssions,
      customizations: {

      }
    }
  end

  def front_permssions
    { statistic: true,
      clients: true,
      authorizations: true,
      congratulations: true,
      sales: true,
      polls: true,
      brands: true,
      locations: true,
      routers: true,
      integrations: true,
      market: true,
      vips: true,
      help: true,
      opinions: true }
  end
end
