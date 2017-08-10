class UpdateClientAccountingLogs < ActiveRecord::Migration[5.0]
  def change
    remove_column :client_accounting_logs, :account_session
    remove_column :client_accounting_logs, :username
    remove_column :client_accounting_logs, :account_start
    remove_column :client_accounting_logs, :account_end
    add_column :client_accounting_logs, :acctsessionid, :string
    add_column :client_accounting_logs, :acctuniqueid, :string
    add_column :client_accounting_logs, :username, :string
    add_column :client_accounting_logs, :groupname, :string
    add_column :client_accounting_logs, :realm, :string
    add_column :client_accounting_logs, :nasipaddress, :string
    add_column :client_accounting_logs, :nasportid, :string
    add_column :client_accounting_logs, :nasporttype, :string
    add_column :client_accounting_logs, :acctstarttime, :datetime
    add_column :client_accounting_logs, :acctstoptime, :datetime
    add_column :client_accounting_logs, :acctsessiontime, :bigint
    add_column :client_accounting_logs, :acctauthentic, :string
    add_column :client_accounting_logs, :connectinfo_start, :string
    add_column :client_accounting_logs, :connectinfo_stop, :string
    add_column :client_accounting_logs, :acctinputoctets, :bigint
    add_column :client_accounting_logs, :acctoutputoctets, :bigint
    add_column :client_accounting_logs, :calledstationid, :string
    add_column :client_accounting_logs, :callingstationid, :string
    add_column :client_accounting_logs, :acctterminatecause, :string
    add_column :client_accounting_logs, :servicetype, :string
    add_column :client_accounting_logs, :xascendsessionsvrkey, :string
    add_column :client_accounting_logs, :framedprotocol, :string
    add_column :client_accounting_logs, :framedipaddress, :string
    add_column :client_accounting_logs, :acctstartdelay, :integer
    add_column :client_accounting_logs, :acctstopdelay, :integer
    add_index :client_accounting_logs, [:username]
    # add_index :auth_logs, [:username]
    add_index :client_accounting_logs, [:acctstarttime]
    add_index :client_accounting_logs, [:acctstoptime]
    add_index :client_accounting_logs, [:nasipaddress]
    add_index :client_accounting_logs, [:nasportid]
    add_index :client_accounting_logs, [:calledstationid]
  end
end
