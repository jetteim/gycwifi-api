FactoryGirl.define do
  factory :client_counter do
    client
    location
    counter { Faker::Number.between(1, 10) }
  end
end
