class UpdateAuthLogVoucher < ActiveRecord::Migration[5.0]
  def change
    change_table :auth_logs do |t|
      t.belongs_to :voucher
    end
    change_column_default :vouchers, :duration, 0
  end
end
