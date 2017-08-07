# == Schema Information
#
# Table name: agent_infos
#
#  id                      :integer          not null, primary key
#  referral_id             :integer          not null
#  agent_payment_method_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

RSpec.describe AgentReward, type: :model do
  # it 'should collect reward' do
  #   create(:agent_reward)
  # end
end
