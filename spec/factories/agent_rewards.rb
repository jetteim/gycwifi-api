# == Schema Information
#
# Table name: agent_rewards
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  order_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :agent_reward do
    order
    agent_info
  end
end
