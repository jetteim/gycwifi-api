class CreateOrderStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :order_statuses do |t|
      t.integer :code_cd, null: false
      t.belongs_to :order, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
