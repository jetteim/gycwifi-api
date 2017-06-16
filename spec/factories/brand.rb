FactoryGirl.define do
  factory :brand do
    title { Faker::App.name }
    layout
    category
  end
end
