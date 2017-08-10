class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.integer :transaction_id
      t.integer :status_cd, default: 0
      t.belongs_to :user
      t.belongs_to :product

      t.timestamps
    end
  end
end
