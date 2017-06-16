# Advertisement mailer for our AmoCRM
class NotificationMailer < ApplicationMailer
  default from: 'noreply@gycwifi.com'
  layout 'notification_mailer'
  # queue_as :notification

  def notification_email(router)
    @router = router
    @location = router.location
    @status = router.status ? 'online' : 'offline'
    mail(to: !Rails.env.production? ? 'mlee@key-g.com' : router.user.email, subject: "GYC WiFi - router #{@status}")
  end
end
