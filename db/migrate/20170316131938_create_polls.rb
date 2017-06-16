class CreatePolls < ActiveRecord::Migration[5.0]
  def change
    create_table :polls do |t|
      t.string :title
      t.belongs_to :user
      t.belongs_to :location

      t.timestamps
    end
  end
end
