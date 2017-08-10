class AddBrandTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :brands, :template, :string, default: 'default'
    add_column :brands, :public, :boolean, default: false
    Brand.find_by(id: 1).update(public: true)
  end
end
