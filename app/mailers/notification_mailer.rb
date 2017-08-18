# Advertisement mailer for our AmoCRM
class NotificationMailer < ApplicationMailer
  default from: 'noreply@gycwifi.com'
  layout 'notification_mailer'
  # queue_as :notification

  def notification_email(n)
    location = Location.find_by(id: n.location_id)
    @details = location.routers.each { |router| "#{router.serial} status: #{router.status ? 'online' : 'offline'}<br>" }
    mail(to: !Rails.env.production? ? 'mlee@key-g.com' : location.user.email, subject: n.title)
  end
end
