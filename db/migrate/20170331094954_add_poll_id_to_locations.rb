class AddPollIdToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :poll_id, :integer
  end
end
