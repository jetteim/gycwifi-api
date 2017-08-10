# == Schema Information
#
# Table name: device_auth_pendings
#
#  id         :integer          not null, primary key
#  mac        :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sms_code   :string
#

class DeviceAuthPending < ApplicationRecord
  # Relations
  # Validations
  # Scopes
  # Methods

  def assign_client(client_id)
    client = Client.find_by(id: client_id)
    return unless client
    logger.debug "resolving pending authorization for phone #{phone} to client #{client_id}".blue
    return nil unless client.update(phone_number: phone)
    delete
    client.phone_number
  end
end
