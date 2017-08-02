class DropPaymentsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :payments
    remove_column :notifications, :payment_id
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
