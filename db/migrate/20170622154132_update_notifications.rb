class UpdateNotifications < ActiveRecord::Migration[5.0]
  def change
    change_table :notifications do |t|
      t.remove :status_sent
      t.belongs_to :user
      t.belongs_to :location
      t.belongs_to :poll
      t.belongs_to :payment
    end
    add_index :routers, [:created_at]
    add_index :routers, [:updated_at]
  end
end
