class ChangePriceTypeInProducts < ActiveRecord::Migration[5.0]
  def change
    change_table :products do |t|
      t.change :price, :decimal, precision: 9, scale: 2
    end
  end
end
