# == Schema Information
#
# Table name: order_products
#
#  id         :integer          not null, primary key
#  order_id   :integer          not null
#  product_id :integer          not null
#  price      :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe OrderProduct, type: :model do
  let(:product) { create(:product, price: 100) }

  describe 'price' do
    let(:order_product) { create(:order_product, product: product) }

    it 'should set price for new record' do
      expect(order_product.price).to eq(100)
    end

    it 'should not change price for existent record' do
      new_product = create(:product, price: 110)
      order_product.update(product: new_product)
      expect(order_product.price).to eq(100)
    end
  end
end
