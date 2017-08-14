class CreatePromoCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :promo_codes do |t|
      t.string :code, null: false
      t.integer :agent_id
      t.timestamps
    end
  end
end
