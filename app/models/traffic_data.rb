# == Schema Information
#
# Table name: traffic_data
#
#  mac            :string
#  username       :string
#  ip_name        :string
#  created_at     :datetime
#  last_seen      :datetime
#  total_time     :decimal(, )
#  outgoing_bytes :decimal(, )
#  incoming_bytes :decimal(, )
#

class TrafficData < ApplicationRecord
  # Relations
  belongs_to :client_device, primary_key: :mac, foreign_key: :mac
  belongs_to :auth_log, primary_key: :username, foreign_key: :username
  belongs_to :router, primary_key: :ip_name, foreign_key: :ip_name
  end
