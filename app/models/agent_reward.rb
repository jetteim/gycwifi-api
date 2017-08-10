# == Schema Information
#
# Table name: agent_rewards
#
#  id            :integer          not null, primary key
#  agent_info_id :integer          not null
#  order_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class AgentReward < ApplicationRecord #:nodoc:
  include PaymentStatuses

  belongs_to :agent_info
  belongs_to :order
  has_many :statuses, -> { order(:created_at) }, dependent: :delete_all,
           class_name: 'AgentRewardStatus'

  delegate :user, to: :agent_info

  def payment_total
    order.order_products.map(&:price).sum
  end
end
