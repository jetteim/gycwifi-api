class UpdateNotifications1 < ActiveRecord::Migration[5.0]
  def change
    change_table :notifications do |t|
      t.string :title
      t.string :details
    end
  end
end
