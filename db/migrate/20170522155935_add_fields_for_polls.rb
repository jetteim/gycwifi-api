class AddFieldsForPolls < ActiveRecord::Migration[5.0]
  def change
    add_column :answers, :custom, :boolean, default: false
    add_column :attempts, :custom_answer, :string
  end
end
