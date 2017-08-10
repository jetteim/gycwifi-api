class CreatePostAuthLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :post_auth_logs do |t|
      t.string :username
      t.string :passsword
      t.string :reply
      t.string :calledstationid
      t.string :callingstationid
      t.timestamps
    end
  end
end
