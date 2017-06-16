class AddLocationTemplate < ActiveRecord::Migration[5.0]
  def change
    remove_column :locations, :vaucher
    add_column :locations, :voucher, :boolean, default: true
    add_column :locations, :template, :string, default: 'default'
    create_table :vouchers do |t|
      t.belongs_to :location
      t.string :password
      t.datetime :expiration
      t.timestamps
    end
  end
end
