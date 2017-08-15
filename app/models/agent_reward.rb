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

class AgentReward < ApplicationRecord #:nodoc:
  belongs_to :agent
  belongs_to :order
  has_one :user, through: :order

  validate :reward_status_change

  as_enum :status, unpayed: 0 , payed: 1

  def payment_total
    order.order_products.map(&:price).sum
  end

  private

  def reward_status_change
    return unless status_cd_change && status_cd_change[0] == 1
    errors.add(:status, "Change status of payed reward are not allowed!")
  end
end
