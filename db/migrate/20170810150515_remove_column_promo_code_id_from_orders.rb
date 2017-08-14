class RemoveColumnPromoCodeIdFromOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :promo_code_id, :integer
  end
end
