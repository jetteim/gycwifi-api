class AddLastPageContent < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :last_page_content, :string, default: 'text', null: false
    execute "update locations set last_page_content = 'text' where last_page_content = null"
  end
end
