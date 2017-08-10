# Request password mailer
class RequestPasswordMailer < ApplicationMailer
  default from: 'noreply@gycwifi.com'
  layout 'mailer'
  # queue_as :reset_password

  def request_password(email, password)
    @password = password
    mail(to: email, subject: 'Your new password to GycWiFi Dashboard!')
  end
end
