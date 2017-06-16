class CreateOpinions < ActiveRecord::Migration[5.0]
  def change
    create_table :opinions do |t|
      t.integer :style
      t.text :message
      t.string :location
      t.belongs_to :user

      t.timestamps
    end
  end
end
