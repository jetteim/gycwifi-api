FactoryGirl.define do
  factory :opinion do
    style %w(positive negative).sample
    message { Faker::FamilyGuy.quote }
    location 'localhost'
  end
end
