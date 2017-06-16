class UpdateVouchersDuration < ActiveRecord::Migration[5.0]
  def change
    change_table :vouchers do |t|
      t.integer :duration
    end
  end
end
