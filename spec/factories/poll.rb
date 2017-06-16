FactoryGirl.define do
  factory :poll do
    title { Faker::FamilyGuy.quote }
    user
    trait :with_attempt do
      after(:create) do |poll|
        create(:question, :with_answer, poll: poll)
      end
    end
  end

end
