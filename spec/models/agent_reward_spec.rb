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

require 'rails_helper'

RSpec.describe AgentReward, type: :model do
  # it 'should calculate payment_total' do
  #   agent_reward = create(:agent_reward)
  #   agent_reward.order.order_products = [
  #     create(:order_product),
  #     create(:order_product)
  #   ]
  #   expect(agent_reward.payment_total).to be_positive
  # end
end
