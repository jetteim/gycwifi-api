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

FactoryGirl.define do
  factory :order_product do
    order
    product
  end
end
