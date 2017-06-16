FactoryGirl.define do
  factory :category do
    title_en { Faker::App.name }
    sequence(:title_ru) { |n| "Название#{n}"}
  end
end
