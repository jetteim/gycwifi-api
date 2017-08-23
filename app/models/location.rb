# == Schema Information
#
# Table name: locations
#
#  id                   :integer          not null, primary key
#  title                :string           not null
#  phone                :string
#  address              :string
#  url                  :string           default("https://gycwifi.com")
#  ssid                 :string           not null
#  staff_ssid           :string
#  staff_ssid_pass      :string
#  sms_auth             :boolean          default(TRUE), not null
#  redirect_url         :string           default("https://gycwifi.com"), not null
#  wlan                 :string           default("1M"), not null
#  wan                  :string           default("5M"), not null
#  auth_expiration_time :integer          default(3600), not null
#  promo_text           :text             default("Спасибо за то, что заглянули к нам!"), not null
#  logo                 :string           default("/images/logo.png")
#  bg_color             :string           default("#0e1a35")
#  background           :string           default("/images/default_background.png")
#  sms_count            :integer          default(0), not null
#  password             :boolean          default(FALSE), not null
#  twitter              :boolean          default(FALSE), not null
#  google               :boolean          default(FALSE), not null
#  vk                   :boolean          default(FALSE), not null
#  insta                :boolean          default(FALSE), not null
#  facebook             :boolean          default(FALSE), not null
#  slug                 :string           not null
#  brand_id             :integer          not null
#  category_id          :integer          default(24), not null
#  user_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  last_page_content    :string           default("text"), not null
#  poll_id              :integer
#  voucher              :boolean          default(TRUE)
#

class Location < ApplicationRecord
  # Friendly urls
  # include Skylight::Helpers
  extend FriendlyId
  friendly_id :title_and_address, use: :slugged
  def title_and_address
    [:title, %i[title ssid], %i[title ssid address], %i[title ssid address id]]
  end

  # Optimizing the system for it to understand the Russian language
  def normalize_friendly_id(text)
    text.to_slug.normalize(transliterations: :russian).to_s
  end

  # Methods

  # instrument_method
  def attributes
    super
  end

  def extended_address
    slug
  end

  # instrument_method
  def template
    tmp = RedisCache.cached_brand(brand_id)
    tmp[:template] ? tmp[:template] : 'default'
  end

  def address_completed
    address.present?
  end

  def phone_completed
    phone.present?
  end

  def logo_uploaded
    logo.present?
  end

  def url_completed
    url.present?
  end

  def auth_count
    social_logs.count || 0
  end

  delegate :count, to: :routers, prefix: true

  def providers
    {
      twitter:    twitter && false,
      google:     google,
      vk:         vk,
      instagram:  insta,
      facebook:   facebook,
      password:   password,
      without:    password,
      voucher:    voucher
    }
  end

  def available_vouchers
    vouchers.reject(&:expired?) if voucher
  end

  def activated_vouchers
    vouchers.select(&:activated?) if voucher
  end

  def active_vouchers
    vouchers.select { |voucher| voucher.activated? && !voucher.expired? } if voucher
  end

  # Relations
  belongs_to :brand
  belongs_to :category
  belongs_to :user
  belongs_to :poll
  has_many   :login_menu_items, dependent: :destroy
  has_many   :vouchers, dependent: :destroy
  has_many   :routers, dependent: :destroy
  has_many   :social_logs
  has_many   :client_counters
  has_many   :client_visits
  has_many   :traffic_data, -> { distinct }, through: :routers
  has_many   :traffic_report, -> { distinct }, through: :routers
  has_many   :client_accounting_logs, -> { distinct }, through: :routers
  # has_many    :vips
  # has_many    :social_logs
  # has_many    :bans
  # has_many    :clients

  # Validations
  validates :title, presence: true
  validates :phone, presence: true
  validates :address, presence: true
  validates :ssid, presence: true
  validates :redirect_url, presence: true
  # validates :title, :ssid, :redirect_url, :wlan, :wan,
  #           :auth_expiration_time, :promo_text, :brand_id,
  #           :category_id, :user_id, presence: true
  #
  # validates :address, length: { in: 10..150 }
  # validates :ssid, :staff_ssid, length: { in: 10..150 }
  # validates :staff_ssid_pass, length: { in: 5..15 }
  #
  # validates :category_id, :user_id, numericality: true
  validates :slug, uniqueness: true
  validates :brand_id, numericality: { only_integer: true }

  # Scopes
  scope :user_locations, ->(user_id) { where(user_id: user_id) }

  scope :brand_locations, ->(brand) { where(brand_id: brand) }

  after_update do
    routers.each(&:rebuild)
  end
  # Uploaders
  # mount_uploader :logo, LogoUploader
  # mount_uploader :background, BackgroundUploader
end
