class AddDefaultValueToAgentRewardsStatus < ActiveRecord::Migration[5.0]
  def change
    change_column :agent_rewards, :status_cd, :integer, :default => 0
  end
end
