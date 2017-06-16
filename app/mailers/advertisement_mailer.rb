# Advertisement mailer for our AmoCRM
class AdvertisementMailer < ApplicationMailer
  # queue_as :advertisement
  default from: 'noreply@gycwifi.com'
  # layout 'mailer'

  def advertisement_email(user)
    @username = user.username
    @email    = user.email
    @date     = user.created_at

    mail(to: 'info@gycwifi.com', subject: 'New user on GycWiFi Dashboard')
  end
end
