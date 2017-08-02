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

class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order

  before_validation :set_price

  private

  def set_price
    self.price = product.price if new_record?
  end
end
