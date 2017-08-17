# == Schema Information
#
# Table name: agent_rewards
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  order_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status_cd  :integer          default(0)
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
  let(:payed_reward) { create(:agent_reward, :payed) }
  let(:unpayed_reward) { create(:agent_reward, :unpayed) }

  context 'validates status change' do
    it 'restricts change from payed to unpayed' do
      payed_reward.unpayed!
      payed_reward.save
      expect(payed_reward.errors.messages[:status][0]).to eq('Change status of payed reward are not allowed!')
    end
    it 'permits change from unpayed to payed' do
      unpayed_reward.payed!
      expect(unpayed_reward.save).to eq(true)
    end
  end
end
