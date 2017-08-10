class CreateVips < ActiveRecord::Migration[5.0]
  def change
    create_table :vips do |t|
      t.string :phone
      t.belongs_to :location, index: true

      t.timestamps
    end
  end
end
