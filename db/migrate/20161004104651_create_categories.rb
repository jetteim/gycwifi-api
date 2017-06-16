class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :title_en
      t.string :title_ru

      t.timestamps
    end
  end
end
