class RemoveLocationIdFromPolls < ActiveRecord::Migration[5.0]
  def change
    remove_column :polls, :location_id, :integer
  end
end
