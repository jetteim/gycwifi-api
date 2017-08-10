class CreateSocialAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :social_accounts do |t|
      t.string :provider
      t.string :uid
      t.string :vaucher
      t.string :username
      t.string :image
      t.string :profile
      t.string :email
      t.string :gender
      t.string :location
      t.integer :bdate_day
      t.integer :bdate_month
      t.integer :bdate_year
      t.belongs_to :client, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
