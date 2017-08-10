# == Schema Information
#
# Table name: vouchers
#
#  id          :integer          not null, primary key
#  location_id :integer
#  password    :string
#  expiration  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  client_id   :integer
#  duration    :integer          default(0)
#

FactoryGirl.define do
  factory :voucher do
    location
    client
    expiration { 1.day.since }
  end
end
