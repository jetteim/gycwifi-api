class AddUserParent < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :parent, :integer, default: 274
  end
end
