# == Schema Information
#
# Table name: layouts
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  local_path :string
#

class Layout < ApplicationRecord
  # Relations
  has_many :brands
end
