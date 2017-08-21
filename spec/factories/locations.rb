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

FactoryGirl.define do
  factory :location do
    title { Faker::App.name }
    phone { Faker::PhoneNumber.cell_phone }
    address { Faker::Address.street_address }
    url { Faker::Internet.url }
    ssid 'WiFi'
    staff_ssid ''
    staff_ssid_pass ''
    redirect_url { Faker::Internet.url }
    wlan '1M'
    wan '5M'
    auth_expiration_time 900
    slug { Faker::Internet.slug }
    sms_auth false
    sms_count 0
    brand
    user
    trait :with_social_log do
      after(:create) do |loc|
        create(:social_log, location: loc)
      end
    end
  end
end
