class RenameAgentInfoToAgent < ActiveRecord::Migration[5.0]
  def change
    rename_table :agent_infos, :agents
  end
end
