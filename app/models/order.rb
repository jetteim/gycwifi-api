# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Order < ApplicationRecord
  include PaymentStatuses

  belongs_to :user
  has_many :order_products, dependent: :delete_all
  has_many :products, through: :order_products
  has_many :statuses, -> { order(:created_at) }, dependent: :delete_all,
           class_name: 'OrderStatus'

  validates :user, presence: true
end
