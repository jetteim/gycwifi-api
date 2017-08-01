# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string           not null
#  email      :string           not null
#  password   :string           not null
#  avatar     :string           default("/images/avatars/default.jpg")
#  role_cd    :integer          default(0), not null
#  tour       :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lang       :string           default("ru")
#  sms_count  :integer
#  user_id    :integer          default(274)
#  expiration :datetime         default(Mon, 05 Jun 2017 06:29:47 UTC +00:00)
#

class User < ApplicationRecord
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
  has_many :orders, dependent: :delete_all
  has_many :users
  has_many :payments
  belongs_to :user

  include Skylight::Helpers
  # Validations
  # validates :username, :email, :password, :role_cd, :tour, presence: true
  validates :username, length: { maximum: 100 }
  # validates :email, length: { maximum: 100 }
  # validates :password, length: { minimum: 5, maximum: 100 }

  # Uploaders
  # mount_uploader :avatar, AvatarUploader

  # Roles
  as_enum :role, free: 0, pro: 1, exclusive: 2, admin: 3, engineer: 4, agent: 5, employee: 6, operator: 7, manager: 8

  instrument_method
  def attributes
    super.merge(
      active_role: active_role,
      locations_count: locations_count,
      routers_count: routers_count,
      brands_count: brands_count,
      polls_count: polls_count,
      super_user: super_user?,
      power_user: power_user?,
      can_manage_child_items: can_manage_child_items?,
      can_create_as_child: can_create_as_child?,
      can_view_child_items: can_view_child_items?,
      can_view_peer_items: can_view_peer_items?,
      can_view_owner_items: can_view_owner_items?,
      can_create_normal_users: can_create_normal_users?,
      can_create_employees: can_create_employees?,
      pro: pro?,
      exclusive: exclusive?
    )
  end

  # methods
  instrument_method
  def active_role
    return role unless expiration
    DateTime.current < expiration ? role : 'free'
  end

  instrument_method
  def locations_count
    locations.pluck(:id).count || 0
  end

  instrument_method
  def brands_count
    brands.pluck(:id).count || 0
  end

  instrument_method
  def routers_count
    routers.pluck(:id).count || 0
  end

  instrument_method
  def polls_count
    polls.pluck(:id).count || 0
  end

  # roles definitions
  def super_user?
    admin? || engineer?
  end

  def super_user
    super_user?
  end

  def power_user?
    super_user? || operator? || manager? || agent?
  end

  def power_user
    power_user?
  end

  def can_manage_child_items?
    super_user? || operator?
  end

  def can_manage_child_items
    can_manage_child_items?
  end

  def can_create_as_child?
    super_user? || operator?
  end

  def can_create_as_child
    can_create_as_child?
  end

  def can_view_child_items?
    super_user? || operator? || manager?
  end

  def can_view_child_items
    can_view_child_items?
  end

  def can_view_peer_items?
    employee?
  end

  def can_view_peer_items
    can_view_peer_items?
  end

  def can_view_owner_items?
    employee?
  end

  def can_view_owner_items
    can_view_owner_items?
  end

  def can_create_normal_users?
    power_user?
  end

  def can_create_normal_users
    can_create_normal_users?
  end

  def can_create_employees?
    can_create_normal_users? || pro? || exclusive?
  end

  def can_create_employees
    can_create_employees?
  end

  # def operator?
  #   role.in?([:operator])
  # end
  #
  # def manager?
  #   role.in?([:manager])
  # end
  #
  # def agent?
  #   role.in?([:agent])
  # end
  #
  def pro?
    role.in?([:pro]) || (employee? && user&.pro?)
  end

  def pro
    pro?
  end

  def exclusive?
    role.in?([:exclusive]) || (employee? && user&.exclusive?)
  end

  def exclusive
    exclusive?
  end

  # def free?
  #   role.in?([:free])
  # end
  #
  # def employee?
  #   role.in?([:employee])
  # end
  #
  def owner
    user
  end

  def peers
    owner.users
  end
end
