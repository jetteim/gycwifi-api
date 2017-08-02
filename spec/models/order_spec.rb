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
end
