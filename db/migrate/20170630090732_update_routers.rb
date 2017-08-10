class UpdateRouters < ActiveRecord::Migration[5.0]
  def change
    change_table :routers do |t|
      t.string :config_type
      t.string :hotspot_interface
      t.string :hotspot_address
    end
  end
end
