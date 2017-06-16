class AddUserExpiration < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :expiration, :timestamp, default: Time.current
  end
end
