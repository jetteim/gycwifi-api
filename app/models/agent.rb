# == Schema Information
#
# Table name: agents
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  agent_payment_method_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Agent < ApplicationRecord #:nodoc:
  has_many :agent_rewards

  has_many :promo_codes
  has_many :referrals, through: :promo_codes

  belongs_to :agent_payment_method
  belongs_to :user

  after_create do
    user.touch
  end
end
