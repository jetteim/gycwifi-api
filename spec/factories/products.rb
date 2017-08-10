# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  price       :integer
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :product do
    name        { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    price       { Faker::Commerce.price }
  end
end
