FactoryGirl.define do
  factory :attempt do
    custom_answer nil
    interview_uuid { SecureRandom.uuid }
    client
  end
end
