# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  title         :string
#  question_type :string
#  poll_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Question < ApplicationRecord
  # Relations
  belongs_to :poll
  has_many   :answers, -> { order(:id) }, dependent: :destroy
  has_many   :attempts, through: :answers

  include Skylight::Helpers

  instrument_method
  def attributes
    super
  end
end
