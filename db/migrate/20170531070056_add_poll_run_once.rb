class AddPollRunOnce < ActiveRecord::Migration[5.0]
  def change
    add_column :polls, :run_once, :boolean, default: true
  end
end
