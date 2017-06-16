class UpdateUser < ActiveRecord::Migration[5.0]
  def change
    change_table :notifications do |t|
      t.timestamp :tour_last_run
      t.boolean :silence, default: false
    end
  end
end
