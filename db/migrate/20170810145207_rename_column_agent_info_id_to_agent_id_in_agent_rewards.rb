class RenameColumnAgentInfoIdToAgentIdInAgentRewards < ActiveRecord::Migration[5.0]
  def change
    rename_column  :agent_rewards, :agent_info_id, :agent_id
  end
end
