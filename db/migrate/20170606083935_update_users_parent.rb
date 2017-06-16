class UpdateUsersParent < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :parent, :user_id
    # add_reference :users, :user, foreign_key: true
    add_index :delayed_jobs, [:queue], name: 'delayed_jobs_queue'
  end
end
