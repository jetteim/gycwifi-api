# == Schema Information
#
# Table name: agent_payment_methods
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AgentPaymentMethod < ApplicationRecord #:nodoc:
  validates :name, presence: true
  has_many :agents
end
