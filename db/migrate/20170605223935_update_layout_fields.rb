class UpdateLayoutFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :layouts, :css
    remove_column :layouts, :brand_id
    remove_column :locations, :template
    add_column :layouts, :local_path, :string
    add_column :brands, :layout_id, :integer, default: 1
    add_index :brands, [:layout_id]
    Layout.find_or_create_by(id: 1).update(title: 'default', local_path: 'default')
    Layout.find_or_create_by(id: 2).update(title: 'cloudy', local_path: 'cloudy')
    Layout.find_or_create_by(id: 3).update(title: 'light', local_path: 'light')
  end
end
