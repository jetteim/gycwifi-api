# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  title      :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  run_once   :boolean          default(TRUE)
#

# Работа с данными Опросов
class Poll < ApplicationRecord
  # Relations
  belongs_to :user
  has_many   :locations
  has_many   :questions, dependent: :destroy
  has_many   :answers, through: :questions, dependent: :destroy
  has_many   :attempts, through: :answers, dependent: :destroy

  # Scopes
  scope :user_polls, ->(user_id) { where(user_id: user_id) }
  # include Skylight::Helpers

  # instrument_method
  def attributes
    super
  end
end
