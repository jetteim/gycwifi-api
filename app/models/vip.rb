# == Schema Information
#
# Table name: vips
#
#  id          :integer          not null, primary key
#  phone       :string
#  location_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Vip < ApplicationRecord
end
