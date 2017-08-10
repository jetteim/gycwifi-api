class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email, null: false, unique: true, index: true
      t.string :password, null: false
      t.string :avatar, default: '/images/avatars/default.jpg'
      t.integer :role_cd, null: false, default: 0, index: true
      t.boolean :tour, null: false, default: true

      t.timestamps
    end
  end
end
