# == Schema Information
#
# Table name: vouchers
#
#  id          :integer          not null, primary key
#  location_id :integer
#  password    :string
#  expiration  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  client_id   :integer
#  duration    :integer          default(0)
#

class Voucher < ApplicationRecord
  include Skylight::Helpers
  belongs_to :location
  has_many :auth_logs

  instrument_method
  def attributes
    super.merge(activated: activated, expired: expired)
  end

  instrument_method
  def activate(client)
    self.client_id = client
    self.expiration = DateTime.current + duration.minutes
    logger.debug "voucher duration: #{duration}, current time: #{DateTime.current}, expiration set to #{expiration}"
    RedisCache.flush('location', location_id)
    logger.info "ваучер #{inspect} активирован".blue
    save!
  end

  instrument_method
  delegate :user_id, to: :location

  def expired?
    expiration < DateTime.current
  end

  def activated
    activated?
  end

  def expired
    expired?
  end

  def activated?
    client_id.present?
  end

  delegate :user, to: :location
end
