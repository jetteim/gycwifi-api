class AddUniqnessToUserFields < ActiveRecord::Migration[5.0]
  def change
    add_index :users, %i[username email], unique: true
  end
end
