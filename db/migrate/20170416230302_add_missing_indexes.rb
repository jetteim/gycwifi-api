class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :post_auth_logs, [:callingstationid]
    add_index :attempts, [:interview_id]
    add_index :attempts, [:poll_id]
    add_index :attempts, [:client_id]
    add_index :attempts, [:question_id]
    add_index :attempts, [:answer_id]
    add_index :post_auth_logs, [:username]
    #    add_index :post_auth_logs, [:callingstationid]
    add_index :bans, [:until_date]
    #    add_index :brand, [:user_id]
    add_index :client_accounting_logs, [:acctsessionid]
    add_index :client_accounting_logs, [:acctuniqueid]
    add_index :client_accounting_logs, [:callingstationid]
    add_index :locations, [:poll_id]
    #    add_index :locations, [:user_id]
    #    add_index :locations, [:user_id]
    #    add_index :locations, [:user_id]
    add_index :payments, [:transaction_id]
    add_index :sms_logs, [:location_id]
    add_index :social_accounts, [:uid]
    add_index :social_logs, [:social_account_id]
    #    add_index :social_logs, [:provider]
    tables = ActiveRecord::Base.connection.tables - ['schema_migrations']
    tables.each do |table|
      #      add_index table, :created_at unless table == :slugs
      #      add_index table, :updated_at unless table == :slugs
    end
  end
end
