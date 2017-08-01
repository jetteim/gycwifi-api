FactoryGirl.define do
  factory :notification do
    poll
    user
    location
    payment
    router
    seen false
    silence false
    favorite false
    sent_at { 1.second.ago }
  end
end
