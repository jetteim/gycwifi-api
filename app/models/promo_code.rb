# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :integer
#

class PromoCode < ApplicationRecord
  belongs_to :agent
  has_many :referrals, class_name: 'User'

  def self.generate_for_agent(agent)
    promo_code = new(agent: agent, code: GeneratePromoCodeService.call)
    promo_code if promo_code.save
  end
end
