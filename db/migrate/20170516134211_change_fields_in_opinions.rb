class ChangeFieldsInOpinions < ActiveRecord::Migration[5.0]
  def change
    change_table :opinions do |_t|
      change_column :opinions, :style, :string
    end
  end
end
