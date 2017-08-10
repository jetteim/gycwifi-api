class AddVaucherToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :vaucher, :string
  end
end
