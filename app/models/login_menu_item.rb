# == Schema Information
#
# Table name: login_menu_items
#
#  id          :integer          not null, primary key
#  url         :string
#  title_ru    :string
#  title_en    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer
#

class LoginMenuItem < ApplicationRecord
  belongs_to :location
end
