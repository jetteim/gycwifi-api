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

FactoryGirl.define do
  factory :agent_info do
    user
    referral
    agent_payment_method
  end
end
