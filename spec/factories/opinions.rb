# == Schema Information
#
# Table name: opinions
#
#  id         :integer          not null, primary key
#  style      :string
#  message    :text
#  location   :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :opinion do
    style %w[positive negative].sample
    message { Faker::FamilyGuy.quote }
    location 'localhost'
  end
end
