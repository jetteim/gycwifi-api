class CreateBans < ActiveRecord::Migration[5.0]
  def change
    create_table :bans do |t|
      t.datetime :until_date
      t.belongs_to :location, index: true
      t.belongs_to :client, index: true

      t.timestamps
    end
  end
end
