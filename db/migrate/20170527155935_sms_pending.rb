class SmsPending < ActiveRecord::Migration[5.0]
  def change
    add_column :device_auth_pendings, :sms_code, :string
  end
end
