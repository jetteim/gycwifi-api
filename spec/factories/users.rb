# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string           not null
#  email      :string           not null
#  password   :string           not null
#  avatar     :string           default("/images/avatars/default.jpg")
#  type       :string           default("FreeUser"), not null
#  tour       :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lang       :string           default("ru")
#  sms_count  :integer
#  user_id    :integer          default(274)
#  expiration :datetime         default(Mon, 05 Jun 2017 06:29:47 UTC +00:00)
#

FactoryGirl.define do
  factory :free_user, aliases: %i[user referral] do
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    lang :en

    trait(:admin)     { type 'AdminUser' }
    trait(:pro)       { type 'ProUser' }
    trait(:exclusive) { type 'ExclusiveUser' }
    trait(:agent)     { type 'AgentUser' }
    trait(:employee)  { type 'EmployeeUser' }
    trait(:operator)  { type 'OperatorUser' }
    trait(:manager)   { type 'ManagerUser' }

    trait :power_user do
      type %w[AdminUser EngineerUser AgentUser OperatorUser ManagerUser].sample
    end

    trait :super_user do
      type %w[AdminUser EngineerUser].sample
    end

    trait :with_agent_info do
      type 'AgentUser'
      agent_info
    end
  end
end
