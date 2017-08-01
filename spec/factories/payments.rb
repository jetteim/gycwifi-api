FactoryGirl.define do
  factory :payment do
    user
    product
    status_cd 0
  end
end
