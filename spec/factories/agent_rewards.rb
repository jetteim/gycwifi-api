# == Schema Information
#
# Table name: agent_rewards
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  order_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status_cd  :integer
#  amount     :decimal(9, 2)
#

FactoryGirl.define do
  factory :agent_reward do
    order
    agent
    trait :payed do
      status_cd 1
    end
    trait :unpayed do
      status_cd 0
    end

  end
end
