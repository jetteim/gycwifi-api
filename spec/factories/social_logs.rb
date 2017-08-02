# == Schema Information
#
# Table name: social_logs
#
#  id                :integer          not null, primary key
#  social_account_id :integer
#  provider          :string
#  location_id       :integer
#  router_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :social_log do
    social_account
    provider { social_account.provider }
    location
    router
  end
end
