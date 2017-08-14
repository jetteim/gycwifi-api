class AddColumnPromoCodeIdToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :promo_code_id, :integer
  end
end
