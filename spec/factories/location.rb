FactoryGirl.define do
  factory :location do
    title { Faker::App.name }
    phone { Faker::PhoneNumber.cell_phone }
    address { Faker::Address.street_address }
    url { Faker::Internet.url }
    ssid "WiFi"
    staff_ssid ""
    staff_ssid_pass ""
    redirect_url { Faker::Internet.url }
    wlan "1M"
    wan "5M"
    auth_expiration_time 900
    slug { Faker::Internet.slug }
    promo_type "text"
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
