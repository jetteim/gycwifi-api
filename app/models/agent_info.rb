# == Schema Information
#
# Table name: agent_infos
#
#  id                      :integer          not null, primary key
#  referral_id             :integer          not null
#  agent_payment_method_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class AgentInfo < ApplicationRecord #:nodoc:
  belongs_to :referral, class_name: 'AgentUser'
  belongs_to :agent_payment_method
  has_one :agent_reward, dependent: :destroy
end
