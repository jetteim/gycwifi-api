class CreateClientTrackers < ActiveRecord::Migration[5.0]
  def change
    create_table :client_counters do |t|
      t.belongs_to :client
      t.belongs_to :location
      t.integer    :counter
      t.timestamps
    end
  end
end
