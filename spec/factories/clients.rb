# == Schema Information
#
# Table name: clients
#
#  id           :integer          not null, primary key
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :client do
    phone_number { Faker::PhoneNumber.phone_number }
  end
end
