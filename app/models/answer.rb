# == Schema Information
#
# Table name: answers
#
#  id          :integer          not null, primary key
#  title       :string
#  question_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  custom      :boolean          default(FALSE)
#

class Answer < ApplicationRecord
  # Relations
  include Skylight::Helpers
  belongs_to  :question
  has_many    :attempts, dependent: :destroy

  instrument_method
  def attributes
    super
  end
  instrument_method
  delegate :count, to: :attempts, prefix: true
end
