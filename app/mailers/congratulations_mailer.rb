# Congratulations mailer
class CongratulationsMailer < ApplicationMailer
  # default from: 'noreply@gycwifi.com'
  # layout 'mailer'
  # queue_as :congrats

  def via_email(message, client_email, subject)
    @message = message

    mail(from: 'noreply@gycwifi.com',
         to: client_email,
         body: @message,
         content_type: 'text/plain',
         subject: subject)
  end
end
