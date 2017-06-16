FactoryGirl.define do
  factory :question do
    title { Faker::FamilyGuy.quote }
    trait :with_answer do
      after(:create) do |question|
        create(:answer, :with_attempt, question: question)
      end
    end
  end


end
