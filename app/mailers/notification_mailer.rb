# Advertisement mailer for our AmoCRM
class NotificationMailer < ApplicationMailer
  default from: 'noreply@gycwifi.com'
  layout 'notification_mailer'
  # queue_as :notification

  def notification_email(n)
    location = Location.find_by(id: n.location_id)
    @header = "#{location.title} - #{location.address} - #{n.sent_at}"
    @lines = []
    location.routers.each do |router|
      @lines << "Router #{router.serial} status: #{router.status ? 'online' : 'offline'}"
    end
    mail(to: !Rails.env.production? ? 'mlee@key-g.com' : location.user.email, subject: n.title)
  end
end
