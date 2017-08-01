FactoryGirl.define do
  factory :voucher do
    location
    client
    expiration { 1.day.since }
  end
end
