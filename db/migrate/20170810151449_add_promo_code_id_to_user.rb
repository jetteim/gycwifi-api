class AddPromoCodeIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :promo_code_id, :integer
  end
end
