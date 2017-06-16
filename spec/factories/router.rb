FactoryGirl.define do
  factory :router do
     sequence(:serial) { |n| "643705CA5E36/533#{n}" }
     sequence(:comment) { |n| "comment 1#{n}" }
     first_dns_server '8.8.8.8'
     second_dns_server '8.8.4.4'
     common_name 'client58'
     ip_name 'ip_name'
     router_local_ip { Faker::Internet.ip_v4_address }
     disable_service_access true
     split_networks true
     isolate_wlan true
     block_service_ports true
     admin_ethernet_port "ether5"
     router_admin_ip { Faker::Internet.ip_v4_address }
     admin_password 'admin'
     radius_secret 'secret'
     ssl_certificate 'ssl_certificate'
     ssl_key 'ssl_key'
     radius_db_nas_id { rand(1000).to_s }
     status true
     location
     user
     config_type nil
     hotspot_interface nil
     hotspot_address nil
  end
end
