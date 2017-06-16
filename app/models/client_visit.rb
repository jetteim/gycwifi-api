# == Schema Information
#
# Table name: client_visits
#
#  location_id  :integer
#  client_id    :integer
#  phone_number :string
#  visits       :integer
#  updated_at   :datetime
#

class ClientVisit < ApplicationRecord
  belongs_to  :client
  belongs_to  :location
end
