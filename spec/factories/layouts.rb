FactoryGirl.define do
  factory :layout do
    title { Faker::App.name }
    local_path { Faker::Internet.url }
  end
end
