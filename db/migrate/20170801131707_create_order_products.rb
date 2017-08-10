class CreateOrderProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :order_products do |t|
      t.belongs_to :order, foreign_key: true, null: false
      t.belongs_to :product, foreign_key: true, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.timestamps null: false
    end
  end
end
