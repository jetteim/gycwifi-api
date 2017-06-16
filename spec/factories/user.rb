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
  end
end
