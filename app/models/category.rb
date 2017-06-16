# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  title_en   :string
#  title_ru   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ApplicationRecord
end
