class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.boolean :status_sent
      t.timestamp :sent_at, index: true
      t.belongs_to :router, index: true
      t.timestamps
    end
  end
end
