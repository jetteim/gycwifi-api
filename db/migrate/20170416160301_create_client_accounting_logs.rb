class CreateClientAccountingLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :client_accounting_logs do |t|
      t.string :account_session, index: true
      t.string :username, index: true
      t.datetime :account_start, index: true
      t.datetime :account_end, index: true
      t.timestamps
    end
  end
end
