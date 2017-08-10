# == Schema Information
#
# Table name: brands
#
#  id                   :integer          not null, primary key
#  title                :string           default("GYC Free WiFi"), not null
#  logo                 :string           default("/images/logo.png")
#  bg_color             :string           default("#0e1a35")
#  background           :string           default("/images/default_background.png")
#  redirect_url         :string           default("https://gycwifi.com")
#  auth_expiration_time :integer          default(3600), not null
#  category_id          :integer          not null
#  promo_text           :text             default("Sample promo text")
#  slug                 :string           not null
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sms_auth             :boolean
#  template             :string           default("default")
#  public               :boolean          default(FALSE)
#  layout_id            :integer          default(1)
#

class Brand < ApplicationRecord
  # Friendly urls
  include Skylight::Helpers
  extend FriendlyId
  # Relations
  has_many   :locations, dependent: :destroy
  belongs_to :category
  belongs_to :user
  belongs_to :layout

  # Validations
  validates :title, :auth_expiration_time, :category_id, presence: true

  validates :title, length: { in: 1..32 }
  validates :category_id, numericality: { only_integer: true }
  validates :slug, uniqueness: true

  # Scopes
  scope :user_brands, ->(user_id) { where(user_id: user_id) }

  # friendly_id :title, use: :slugged
  friendly_id :title_category_template, use: :slugged

  def title_category_template
    [:title, %i[title category], %i[title category template]]
  end

  # Optimizing the system for it to understand the Russian language
  def normalize_friendly_id(text)
    text.to_slug.normalize(transliterations: :russian).to_s
  end

  instrument_method
  def attributes
    super
  end

  def template
    tmp = RedisCache.cached_layout(layout_id)
    tmp[:local_path] ? tmp[:local_path] : 'default'
  end
end
