# == Schema Information
#
# Table name: order_statuses
#
#  id         :integer          not null, primary key
#  code_cd    :integer          not null
#  order_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OrderStatus < ApplicationRecord
  belongs_to :order
  as_enum :code, success: 0, auth_error: 1, denied: 100, error: 200
end
