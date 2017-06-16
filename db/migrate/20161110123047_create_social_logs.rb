class CreateSocialLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :social_logs do |t|
      t.integer :social_account_id
      t.string :provider, index: true
      t.belongs_to :location, index: true
      t.belongs_to :router, index: true

      t.timestamps
    end
  end
end
