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

FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    lang :en
    role_cd 0

    trait :admin do
      role_cd 3
    end

    trait :pro do
      role_cd 1
    end

    trait :exclusive do
      role_cd 2
    end

    trait :employee do
      role_cd 6
    end

    trait :operator do
      role_cd 7
    end

    trait :manager do
      role_cd 8
    end

    trait :power_user do
      role_cd [3, 4, 5, 7, 8].sample
    end

    trait :super_user do
      role_cd [3, 4].sample
    end
  end
end
