class AddIndexAgentIdInPromoCodes < ActiveRecord::Migration[5.0]
  def change
    add_index :promo_codes, :agent_id
  end
end
