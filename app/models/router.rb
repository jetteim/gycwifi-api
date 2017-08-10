# == Schema Information
#
# Table name: routers
#
#  id                     :integer          not null, primary key
#  serial                 :string
#  comment                :string
#  first_dns_server       :string           default("8.8.8.8")
#  second_dns_server      :string           default("8.8.4.4")
#  common_name            :string
#  ip_name                :string
#  router_local_ip        :string           default("192.168.88.1")
#  disable_service_access :boolean          default(TRUE)
#  split_networks         :boolean          default(TRUE)
#  isolate_wlan           :boolean          default(TRUE)
#  block_service_ports    :boolean          default(TRUE)
#  admin_ethernet_port    :string           default("ether5")
#  router_admin_ip        :string           default("192.168.10.1")
#  admin_password         :string           default("admin")
#  radius_secret          :string
#  ssl_certificate        :text
#  ssl_key                :text
#  radius_db_nas_id       :string
#  status                 :boolean
#  location_id            :integer
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  config_type            :string
#  hotspot_interface      :string
#  hotspot_address        :string
#

require 'rest-client'
require 'json'
# require 'radius'
require 'ssl'
require 'zip_file_generator'
require 'fileutils'

class Router < ApplicationRecord
  # Relations
  include Skylight::Helpers
  belongs_to :location
  belongs_to :user
  has_many :notifications
  has_many :client_accounting_logs, primary_key: :ip_name, foreign_key: :nasipaddress
  has_many :traffic_data, primary_key: :ip_name, foreign_key: :ip_name
  has_many :traffic_report, primary_key: :ip_name, foreign_key: :ip_name
  has_many :social_logs

  # Validations
  # validates :serial, :first_dns_server, :second_dns_server, :common_name,
  #           :ip_name, :router_local_ip, :admin_ethernet_port, :router_admin_ip,
  #           :admin_password, :radius_secret, :ssl_certificate, :ssl_key,
  #           :radius_db_nas_id, :location_id, :user_id, presence: :true
  validates :serial, presence: true
  validates :serial, uniqueness: true

  # validates :serial, length: { maximum: 32 }
  # validates :admin_password, length: { in: 5..32 }

  # TODO: need more information
  # validates :radius_secret, length: { in: 6..32 }

  # validates :comment, length: { maximum: 50 }

  # validates :location_id, :user_id, numericality: true

  # Scopes
  scope :location_routers, ->(locations) { where(location: locations) }

  # Обновляем архивы
  after_update do
    rebuild
  end

  instrument_method
  def attributes
    super
  end

  # Дополняем данные о роутере при создании
  after_create do
    # Variables
    admin_password ||= SecureRandom.hex(8)
    common_name    ||= 'client' + id.to_s
    radius_secret  ||= SecureRandom.hex(8)
    ip_name        ||=
      '10.8.' + ((id + 10) / 255).to_s + '.' + ((id + 10) % 255).to_s
    ssl_gen = SSLGenerator.new.load_ca(
      'ca.crt', 'ca.key', Rails.root.join('config', 'certificates')
    )
    @config ||= YAML.load_file(File.join(Rails.root, 'config', 'mtpackager.yml'))
    ssl_gen = ssl_gen.set_dn(@config['ssl'])
    ssl_gen = ssl_gen.set_name(common_name).generate.tupple
    # Update data in DB
    self.ssl_certificate  ||= ssl_gen['crt']
    self.ssl_key          ||= ssl_gen['key']
    self.common_name      ||= common_name
    self.radius_secret    ||= radius_secret
    self.ip_name          ||= ip_name
    self.radius_db_nas_id = id
    self.admin_password = admin_password
    save!
  end

  instrument_method
  def wan
    Location.exists?(location_id) ? location.wlan : '10M'
  end

  instrument_method
  def wlan
    Location.exists?(location_id) ? location.wlan : '1M'
  end

  # Обновление роутера и создание архива
  instrument_method
  def package
    @config ||= YAML.load_file(File.join(Rails.root, 'config', 'mtpackager.yml'))
    @destination_root = Rails.root.join('public', 'router_files', common_name)
    @source_root      = Rails.root.join('lib', "#{config_type || 'mikrotik_ap'}_template")
    FileUtils.rmtree(@destination_root)
    FileUtils.mkdir_p(@destination_root)
    build_package(@source_root, @destination_root)
    generate_keys(File.join(@destination_root, 'flash'))
    ZipFileGenerator.zipdir(@destination_root, File.join(@destination_root, (common_name + '.zip')))
  end

  # Создание архива
  instrument_method
  def build_package(source, target)
    list = Dir.glob(File.join(source, '**'))
    # process each file in the give dir
    list.each do |source_file|
      # lookup into directory if found
      target_file = File.join(target, File.basename(source_file))
      FileUtils.mkdir_p(target_file) if File.directory?(source_file)
      build_package(source_file, target_file) if File.directory?(source_file)
      next if File.directory?(source_file)
      target_file = File.join(target, File.basename(source_file).split('.')[0...-1].join('.')) if File.basename(source_file).split('.').last == 'mt'
      # logger.debug {"#{source_file} -> #{target_file}"}
      File.open(target_file, 'w') do |io|
        if File.basename(source_file).split('.').last == 'mt'
          io.write replace_variables(source_file)
        else
          io.write File.read(source_file)
        end
      end
    end
  end

  # Обновление переменных
  instrument_method
  def replace_variables(file)
    data = {}
    data.update(@config['common'])
    data.update(attributes)
    data.update(location.attributes) if location
    new_file = File.read(file)
    mc = /\$\{(.+?)\}/.match(new_file)
    until mc.nil?
      r = mc[0]
      m = mc[1]
      new_file = new_file.sub(r, data[m]&.to_s || '')
      # logger.debug {"replace #{r} -> #{data[m]&.to_s}"} unless data[m].nil?
      # logger.debug {"Can't replace #{r}, not found in common/device data."} if data[m].nil?
      mc = /\$\{(.+?)\}/.match(new_file)
    end
    new_file
  end

  # Генерация ключей
  def generate_keys(path)
    cert_name = 'client.crt'
    key_name  = 'client.pem'
    ca_name = Rails.root.join(@config['common']['ca_cert_file'])
    cert_path = File.join(path, cert_name)
    key_path  = File.join(path, key_name)
    ca_path = File.join(path, 'ca.crt')
    File.open(cert_path, 'w') { |io| io.write ssl_certificate }
    File.open(key_path, 'w') { |io| io.write ssl_key }
    File.open(ca_path, 'w') { |io| io.write File.read(ca_name) }
  end

  instrument_method
  def setup_sequence
    # fname = "#{Rails.root.join('public', 'router_files', common_name)}/flash/install.rsc"
    # fname = "#{Rails.root.join('public', 'router_files', common_name)}/flash/install.rsc"
  end

  instrument_method
  def update_router
    return unless status
    data = {}
    data[:common_name] = self.common_name
    data[:guest_ssid] = location&.ssid
    data[:staff_ssid] = location&.staff_ssid
    data[:staff_pass] = location&.staff_ssid_pass
    data[:hotspotconnectionlimit] = location&.wan
    data[:hotspotbalancerlimit] = location&.wlan
    begin
      RestClient.post "#{hal_address}/change_guest_ssid", data if location&.ssid
      RestClient.post "#{hal_address}/change_staff_ssid", data if location&.staff_ssid
      RestClient.post "#{hal_address}/change_staff_pass", data if location&.staff_ssid_pass
      RestClient.post "#{hal_address}/hotspot_wan_limit", data if location&.wan
      RestClient.post "#{hal_address}/hotspot_wlan_limit", data if location&.wlan
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.warn "updating router #{id} failed: #{e.response}"
    end
  end

  def hal_address
    @config ||= YAML.load_file(File.join(Rails.root, 'config', 'mtpackager.yml'))
    @config['common']['hal_address']
  end

  def updater_url
    @config ||= YAML.load_file(File.join(Rails.root, 'config', 'mtpackager.yml'))
    @config['common']['updater_address'] + '/set_router'
  end

  def rebuild
    RouterUpdater.perform_later(self)
    RouterPackageBuilder.perform_later(self)
  end
end
