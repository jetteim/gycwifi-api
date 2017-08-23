# == Schema Information
#
# Table name: auth_logs
#
#  id               :integer          not null, primary key
#  username         :string
#  password         :string
#  timeout          :integer
#  client_device_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  voucher_id       :integer
#

class AuthLog < ApplicationRecord
  # Relations
  belongs_to :client_device
  belongs_to :voucher
  has_many :traffic_datas, primary_key: :username, foreign_key: :username
  has_many :traffic_reports, primary_key: :username, foreign_key: :username
  has_many :client_accounting_logs, primary_key: :username, foreign_key: :username

  scope :authorizations, ->(locations) {
    joins(:client_accounting_logs).joins(:client_device).joins(:client).joins(:social_account).joins(:routers).where(location_id: locations)
  }
  # include Skylight::Helpers

  # instrument_method
  def attributes
    super
  end
end
