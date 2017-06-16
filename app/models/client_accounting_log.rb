# == Schema Information
#
# Table name: client_accounting_logs
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  acctsessionid        :string
#  acctuniqueid         :string
#  username             :string
#  groupname            :string
#  realm                :string
#  nasipaddress         :string
#  nasportid            :string
#  nasporttype          :string
#  acctstarttime        :datetime
#  acctstoptime         :datetime
#  acctsessiontime      :integer
#  acctauthentic        :string
#  connectinfo_start    :string
#  connectinfo_stop     :string
#  acctinputoctets      :integer
#  acctoutputoctets     :integer
#  calledstationid      :string
#  callingstationid     :string
#  acctterminatecause   :string
#  servicetype          :string
#  xascendsessionsvrkey :string
#  framedprotocol       :string
#  framedipaddress      :string
#  acctstartdelay       :integer
#  acctstopdelay        :integer
#

class ClientAccountingLog < ApplicationRecord
  # Relations
  belongs_to :auth_log, primary_key: :username, foreign_key: :username
  belongs_to :router, primary_key: :nasipaddress, foreign_key: :ip_name
  belongs_to :client_device, primary_key: :callingstationid, foreign_key: :mac
end
