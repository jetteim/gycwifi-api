# == Schema Information
#
# Table name: client_counters
#
#  id          :integer          not null, primary key
#  client_id   :integer
#  location_id :integer
#  counter     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :client_counter do
    client
    location
    counter { Faker::Number.between(1, 10) }
  end
end
