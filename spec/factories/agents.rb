# == Schema Information
#
# Table name: agents
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  agent_payment_method_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

FactoryGirl.define do
  factory :agent do
    user
    agent_payment_method
    trait :with_promo_code do
      after(:create) do |agent|
        create(:promo_code, agent: agent)
      end
    end
  end
end
