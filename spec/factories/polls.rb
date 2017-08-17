# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  title      :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  run_once   :boolean          default(TRUE)
#

FactoryGirl.define do
  factory :poll do
    title { Faker::FamilyGuy.quote }
    user
    trait :with_attempt do
      after(:create) do |poll|
        create(:question, :with_answer_and_attempt, poll: poll)
      end
    end
    trait :with_question_and_answer do
      after(:create) do |poll|
        create(:question, :with_answer, poll: poll)
      end
    end
  end
end
