class CreateClientDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :client_devices do |t|
      t.string :mac, index: true
      t.string :platform_os
      t.string :platform_product
      t.belongs_to :client, index: true

      t.timestamps
    end
  end
end
