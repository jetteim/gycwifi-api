class DropAgentRewardStatusesTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :agent_reward_statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
