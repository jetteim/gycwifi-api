class CreateLoginMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :login_menu_items do |t|
      t.string :url
      t.string :title_ru
      t.string :title_en 
      t.timestamps
      t.belongs_to :location, index: true
    end
  end
end
