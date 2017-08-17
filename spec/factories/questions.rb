# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  title         :string
#  question_type :string
#  poll_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :question do
    title { Faker::FamilyGuy.quote }
    trait :with_answer do
      after(:create) do |question|
        create(:answer, question: question)
      end
    end
    trait :with_answer_and_attempt do
      after(:create) do |question|
        create(:answer, :with_attempt, question: question)
      end
    end
  end
end
