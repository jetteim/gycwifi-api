class CreateAgentRewardStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :agent_reward_statuses do |t|
      t.string :code, null: false
      t.belongs_to :agent_reward, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
