class AddFavoriteColumnToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :favorite, :bool, default: false
  end
end
