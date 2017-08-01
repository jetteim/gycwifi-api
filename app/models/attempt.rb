# == Schema Information
#
# Table name: attempts
#
#  id             :integer          not null, primary key
#  client_id      :integer
#  answer_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  custom_answer  :string
#  interview_uuid :integer
#

class Attempt < ApplicationRecord
  belongs_to :client
  belongs_to :poll
  belongs_to :question
  belongs_to :answer
  include Skylight::Helpers

  scope :group_by_period, ->(period) { group("date_trunc('#{period}', created_at) ") }
  instrument_method
  def attributes
    super
  end
end
