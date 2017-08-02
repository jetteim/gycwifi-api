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

FactoryGirl.define do
  factory :brand do
    title { Faker::App.name }
    layout
    category
    user { create(:user, :pro) }
  end
end
