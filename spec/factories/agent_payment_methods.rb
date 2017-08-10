# == Schema Information
#
# Table name: agent_payment_methods
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :agent_payment_method do
    name { Faker::App.name }
  end
end
