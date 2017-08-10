class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string      :title, null: false
      t.string      :phone
      t.string      :address
      t.string      :url, default: 'https://gycwifi.com'
      t.string      :ssid, defaut: 'GYC WIFI Free', null: false
      t.string      :staff_ssid
      t.string      :staff_ssid_pass
      t.boolean     :sms_auth, default: true, null: false
      t.string      :redirect_url, default: 'https://gycwifi.com', null: false
      t.string      :wlan, default: '1M', null: false
      t.string      :wan, default: '5M', null: false
      t.integer     :auth_expiration_time, default: 3600, null: false
      t.text        :promo_text, default: 'Спасибо за то, что заглянули к нам!', null: false
      t.string      :logo, default: '/images/logo.png'
      t.string      :bg_color, default: '#0e1a35'
      t.string      :background, default: '/images/default_background.png'
      t.integer     :sms_count, default: 0, null: false
      t.boolean     :password, default: false, null: false
      t.boolean     :twitter, default: false, null: false
      t.boolean     :google, default: false, null: false
      t.boolean     :vk, default: false, null: false
      t.boolean     :insta, default: false, null: false
      t.boolean     :facebook, default: false, null: false
      t.string      :slug, null: false
      t.belongs_to  :brand, index: true, null: false
      t.belongs_to  :category, default: 24, index: true, null: false
      t.belongs_to  :user, index: true, null: false

      t.timestamps
    end
  end
end
