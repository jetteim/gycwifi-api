FactoryGirl.define do
  factory :client do
    phone_number { Faker::PhoneNumber.phone_number }
  end
end
