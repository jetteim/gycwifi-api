# Registration mailer
class SignupMailer < ApplicationMailer
  default from: 'noreply@gycwifi.com'
  layout 'mailer'
  # queue_as :signup

  def signup_email(user)
    @user = user
    @username = @user&.username || @user&.email || 'nobody'
    mail(to: @user&.email || 'info@gycwifi.com', subject: 'Welcome to GycWiFi Dashboard!')
  end
end
