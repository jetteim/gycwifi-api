FactoryGirl.define do
  factory :social_log do
    social_account
    provider { social_account.provider }
    location
    router
  end
end
