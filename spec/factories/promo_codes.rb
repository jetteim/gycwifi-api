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

FactoryGirl.define do
  factory :promo_code do
    sequence(:code) { |n| (['0']*(8 - n.to_s.size) << n.to_s).join }
  end
end
