# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'statuses' do
    let(:order) { create(:order, status: :success) }

    it 'should create status' do
      expect(order.status).to eq(:success)
      expect(order.statuses.count).to eq(1)
    end

    it 'should update status if different' do
      order.update(status: :denied)
      expect(order.status).to eq(:denied)
      expect(order.statuses.count).to eq(2)
    end

    it 'should update not status if the same' do
      order.update(status: :denied)
      expect(order.status).to eq(:denied)
      expect(order.statuses.count).to eq(2)
    end
  end

  # describe 'agent rewards' do
  #   let(:user) { create(:user) }
  #   let(:user_with_agent) { create(:user, :with_agent_info) }
  #
  #   it 'should not create agent reward without agent referral' do
  #     create(:order, user: user)
  #     create(:order, user: user)
  #     expect(user.orders.count).to be_zero
  #   end
  #
  #   it 'should create agent reward for first order' do
  #     order = create(:order, user: user)
  #     expect(user.orders.count).to eq(1)
  #     expect(AgentReward.first.order).to eq(order)
  #   end
  #
  #   it 'should not create agent reward for second order' do
  #     create(:order, user: user)
  #     order = create(:order, user: user)
  #     expect(user.orders.count).to eq(2)
  #     expect(AgentReward.first.order).not_to eq(order)
  #   end
  # end
end
