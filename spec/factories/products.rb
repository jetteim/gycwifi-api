FactoryGirl.define do
  factory :product do
    name { Faker::App.name }
    description { Faker::FamilyGuy.quote }
    price { rand(0..1000) }
    type 'default'
  end
end
