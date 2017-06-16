# == Schema Information
#
# Table name: client_counters
#
#  id          :integer          not null, primary key
#  client_id   :integer
#  location_id :integer
#  counter     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ClientCounter < ApplicationRecord
  belongs_to  :client
  belongs_to  :location

  scope :passed, -> { group('client_id').having('count(client_counters.id) = 1') } # you should use having with group by
  scope :regular, -> { group('client_id').having('count(client_counters.id) > 1') }
end
