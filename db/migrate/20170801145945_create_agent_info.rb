class CreateAgentInfo < ActiveRecord::Migration[5.0]
  def change
    create_table :agent_infos do |t|
      t.belongs_to :referral, foreign_key: { to_table: :users }, null: false
      t.belongs_to :agent_payment_method, foreign_key: true
      t.timestamps null: false
    end
  end
end
