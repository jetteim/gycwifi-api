# == Schema Information
#
# Table name: client_devices
#
#  id               :integer          not null, primary key
#  mac              :string
#  platform_os      :string
#  platform_product :string
#  client_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ClientDevice < ApplicationRecord
  # Relations
  has_many :auth_logs, dependent: :destroy
  has_many :client_accounting_logs, primary_key: :mac, foreign_key: :callingstationid
  has_many :post_auth_logs, primary_key: :mac, foreign_key: :callingstationid
  belongs_to :client, dependent: :destroy
  has_many :traffic_data, primary_key: :mac, foreign_key: :mac
  has_many :traffic_report, primary_key: :mac, foreign_key: :mac
end
