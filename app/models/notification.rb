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
#  payment_id    :integer
#  title         :string
#  details       :string
#  seen          :boolean          default(FALSE)
#  tour_last_run :datetime
#  silence       :boolean          default(FALSE)
#

class Notification < ApplicationRecord
  belongs_to :router
  belongs_to :user
  belongs_to :location
  belongs_to :poll
  belongs_to :payment
end
