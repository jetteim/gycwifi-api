# == Schema Information
#
# Table name: opinions
#
#  id         :integer          not null, primary key
#  style      :string
#  message    :text
#  location   :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Opinion < ApplicationRecord
  # Relations
  belongs_to :user
  # Scopes
  # Validations
end
