class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string :phone_number

      t.timestamps
    end
  end
end
