# == Schema Information
#
# Table name: answers
#
#  id          :integer          not null, primary key
#  title       :string
#  question_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  custom      :boolean          default(FALSE)
#

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
