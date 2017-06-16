class CreateBrands < ActiveRecord::Migration[5.0]
  def change
    create_table :brands do |t|
      t.string  :title, default: 'GYC Free WiFi', null: false
      t.string  :logo, default: '/images/logo.png'
      t.string  :bg_color, default: '#0e1a35'
      t.string  :background, default: '/images/default_background.png'
      t.boolean :sms_auth, default: true, null: false
      t.string  :redirect_url, default: 'https://gycwifi.com'
      t.integer :auth_expiration_time, default: 3600, null: false
      t.integer :category_id, null: false
      t.text    :promo_text, default: 'Sample promo text'
      t.string :slug, null: false, unique: true, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
