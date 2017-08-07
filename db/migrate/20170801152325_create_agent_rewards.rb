class CreateAgentRewards < ActiveRecord::Migration[5.0]
  def change
    create_table :agent_rewards do |t|
      t.belongs_to :agent_info, foreign_key: true, null: false
      t.belongs_to :order, foreign_key: true, null: false
      t.timestamps
    end
  end
end
