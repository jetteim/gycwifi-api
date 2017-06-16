FactoryGirl.define do
  factory :answer do
    title { Faker::FamilyGuy.quote }

    trait :with_attempt do
      after(:create) do |answer|
        create(:attempt, answer: answer)
      end
    end
  end
end
