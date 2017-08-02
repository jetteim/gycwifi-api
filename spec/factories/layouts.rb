# == Schema Information
#
# Table name: layouts
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  local_path :string
#

FactoryGirl.define do
  factory :layout do
    title { Faker::App.name }
    local_path { Faker::Internet.url }
  end
end
