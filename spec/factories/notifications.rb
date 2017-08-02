# == Schema Information
#
# Table name: notifications
#
#  id            :integer          not null, primary key
#  sent_at       :datetime
#  router_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#  location_id   :integer
#  poll_id       :integer
#  title         :string
#  details       :string
#  seen          :boolean          default(FALSE)
#  tour_last_run :datetime
#  silence       :boolean          default(FALSE)
#  favorite      :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :notification do
    poll
    user
    location
    router
    seen false
    silence false
    favorite false
    sent_at { 1.second.ago }
  end
end
