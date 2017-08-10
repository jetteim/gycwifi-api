# == Schema Information
#
# Table name: attempts
#
#  id             :integer          not null, primary key
#  client_id      :integer
#  answer_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  custom_answer  :string
#  interview_uuid :integer
#

FactoryGirl.define do
  factory :attempt do
    custom_answer nil
    interview_uuid { SecureRandom.uuid }
    client
  end
end
