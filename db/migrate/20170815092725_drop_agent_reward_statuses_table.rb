class DropAgentRewardStatusesTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :agent_reward_statuses
  end
end
