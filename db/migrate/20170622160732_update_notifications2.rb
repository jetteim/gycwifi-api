class UpdateNotifications2 < ActiveRecord::Migration[5.0]
  def change
    change_table :notifications do |t|
      t.boolean :seen, default: false
    end
  end
end
