class UpdateVouchers < ActiveRecord::Migration[5.0]
  def change
    change_table :vouchers do |t|
      t.belongs_to :client
    end
    add_index :vouchers, [:password]
  end
end
