# == Schema Information
#
# Table name: bans
#
#  id          :integer          not null, primary key
#  until_date  :datetime
#  location_id :integer
#  client_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Ban < ApplicationRecord
end
