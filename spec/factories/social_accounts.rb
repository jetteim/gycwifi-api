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

FactoryGirl.define do
  factory :social_account do
    provider { %w[instagram facebook twitter instagram vk].sample }
    uid { rand(0..1_000_000).to_s }
    vaucher nil
    username { Faker::Internet.user_name }
    image { Faker::Internet.url("#{provider}.com", "/img/#{username}.jpg") }
    profile { "https://#{provider}.com/#{username}" }
    email { Faker::Internet.email }
    gender { %w[male female].sample }
    location 'Москва, Россия'
    bdate_day { rand(1..30) }
    bdate_month { rand(1..12) }
    bdate_year { Faker::Date.birthday(18, 65).year }
    client
    user
  end
end
