# == Schema Information
#
# Table name: clients
#
#  id           :integer          not null, primary key
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Client < ApplicationRecord
  # Relations
  has_many :client_devices
  has_many :social_accounts
  has_many :attempts
  has_many :client_visits
  has_many :client_counters
  has_many :vouchers
  has_many :auth_logs, -> { distinct }, through: :client_devices
  # has_many :sms_logs, -> { distinct }, through: :client_devices
  has_many :client_accounting_logs, -> { distinct }, through: :client_devices
  has_many :social_logs, -> { distinct }, through: :social_accounts
  has_many :traffic_data, -> { distinct }, through: :client_devices
  has_many :traffic_report, -> { distinct }, through: :client_devices

  # Scopes
  scope :clients_on_location, ->(locations) {
    select('phone_number').where.not(clients: { phone_number: nil }).distinct.joins(:social_accounts).joins(:social_logs).where(social_logs: { location: locations })
  }

  scope :clients_on_location_by_date, ->(locations, _start_date = DateTime.current.months_ago(1).beginning_of_day, _end_date = DateTime.current) {
    where.not(clients: { phone_number: nil }).joins(:social_logs).where(social_logs: { location: locations }).joins(:social_accounts).where('social_logs.updated_at between start_date, end_date')
  }

  # Methods
  # instrument_method
  def social_info
    info_keys = %i[username provider email image profile gender birthday].map { |keys| [keys, nil] }.to_h
    social_accounts.inject(info_keys) do |info, s_a|
      info.each_key do |key|
        # если SocialAccount.provider password или voucher, пропускаем его, потому что остальные поля будут nil
        next if (key == :provider) && (value == 'password' || value == 'voucher')
        info[key] ||= s_a.send(key)
      end
    end
    info_keys
  end

  # instrument_method
  def image
    super || '/images/avatars/avatar2.jpg'
  end
end
