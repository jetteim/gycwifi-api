# == Schema Information
#
# Table name: agent_reward_statuses
#
#  id              :integer          not null, primary key
#  code            :string           not null
#  agent_reward_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AgentRewardStatus < ApplicationRecord #:nodoc:
  belongs_to :agent_reward
end
