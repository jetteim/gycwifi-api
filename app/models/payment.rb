# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  transaction_id :integer
#  status_cd      :integer          default(0)
#  user_id        :integer
#  product_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :product
  as_enum :status, success: 0, auth_error: 1, denied: 100, error: 200
end
