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
  # Лучше `dependent: :nullify`. Но что если удалят заказ, за который было
  # выплачено вознаграждение?
  has_one :agent_reward, dependent: :restrict_with_exception

  validates :user, presence: true

  after_create :create_reward

  private

  def create_reward
    return if user.orders.count > 1 || user.promo_code.nil?
    agent_reward.create!(agent_info: user.agent_info)
  end
end
