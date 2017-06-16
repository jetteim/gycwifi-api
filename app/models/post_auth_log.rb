# == Schema Information
#
# Table name: post_auth_logs
#
#  id               :integer          not null, primary key
#  username         :string
#  passsword        :string
#  reply            :string
#  calledstationid  :string
#  callingstationid :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PostAuthLog < ApplicationRecord
  # Relations
  belongs_to :auth_log, primary_key: :username, foreign_key: :username
  belongs_to :client_device, primary_key: :callingstationid, foreign_key: :mac
end
