class NotificationMailerPreview < ActionMailer::Preview
  def notification_email
    NotificationMailer.notification_email(Router.first)
  end
end
