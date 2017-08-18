class AddStatusCdColumnToAgentReward < ActiveRecord::Migration[5.0]
  def change
    add_column :agent_rewards, :status_cd, :integer, after: :id
    add_column :agent_rewards, :amount, :decimal, precision: 9, scale: 2
  end
end
