class CreateDeviceAuthPending < ActiveRecord::Migration[5.0]
  def change
    create_table :device_auth_pending do |t|
      t.string :mac, index: true
      t.string :phone, index: true
      t.timestamps
    end
  end
end
