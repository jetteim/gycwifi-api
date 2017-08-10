class CreateLayouts < ActiveRecord::Migration[5.0]
  def change
    create_table :layouts do |t|
      t.string     :title
      t.text       :css, index: true
      t.belongs_to :brand, index: true

      t.timestamps
    end
  end
end
