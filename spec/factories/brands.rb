FactoryGirl.define do
  factory :brand do
    title { Faker::App.name }
    layout
    category
    user { create(:user, :pro) }
  end
end
