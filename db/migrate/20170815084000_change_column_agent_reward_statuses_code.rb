class ChangeColumnAgentRewardStatusesCode < ActiveRecord::Migration[5.0]
  def change
    remove_column :agent_reward_statuses, :code
    add_column :agent_reward_statuses, :status_cd, :integer
  end
end
