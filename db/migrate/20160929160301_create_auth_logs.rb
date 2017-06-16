class CreateAuthLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :auth_logs do |t|
      t.string :username, index: true
      t.string :password, index: true
      t.integer :timeout
      t.belongs_to :client_device, index: true

      t.timestamps
    end
  end
end
