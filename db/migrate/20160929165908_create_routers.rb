class CreateRouters < ActiveRecord::Migration[5.0]
  def change
    create_table :routers do |t|
      t.string :serial, index: true
      t.string     :comment
      t.string     :first_dns_server, default: '8.8.8.8'
      t.string     :second_dns_server, default: '8.8.4.4'
      t.string     :common_name, index: true
      t.string     :ip_name, index: true
      t.string     :router_local_ip, default: '192.168.88.1'
      t.boolean    :disable_service_access, default: true
      t.boolean    :split_networks, default: true
      t.boolean    :isolate_wlan, default: true
      t.boolean    :block_service_ports, default: true
      t.string     :admin_ethernet_port, default: 'ether5'
      t.string     :router_admin_ip, default: '192.168.10.1'
      t.string     :admin_password, default: 'admin'
      t.string     :radius_secret
      t.text       :ssl_certificate
      t.text       :ssl_key
      t.string     :radius_db_nas_id
      t.boolean    :status
      t.belongs_to :location, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
