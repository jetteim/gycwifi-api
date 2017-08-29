class RouterStatusNotifier < ApplicationJob
  queue_as :routers

  def perform(router = nil)
    return unless Rails.env.production? || Rails.env.staging?
    logger.debug 'starting router status notification check'.red.bold
    (router.blank? ? Router.all.includes(:notifications).includes(:location).includes(:user) : [router]).each do |r|
      # если у роутера status == nil - он ещё не настроен, пропускаем его
      next if r.status.nil?
      notification = r.notifications&.last
      # если последняя нотификация была после даты обновления роутера, отсылать не надо
      next if notification && notification.sent_at > r.updated_at
      # обновляем роутер, создаём нотификацию и отправляем письмо
      r.touch
      sent_at = DateTime.current
      title = "#{r.status ? 'INFO: Router online' : 'WARN: Router offline'} at #{r.location.title}: #{r.serial} - #{r.comment}"
      details = ''
      r.location.routers.each { |rtr| details = "#{details}\n#{rtr.serial} status: #{rtr.status ? 'online' : 'offline'}" }
      # : "WARN: Router online #{r.serial} - #{r.comment}"
      n = Notification.create(
        title: title,
        details: details,
        sent_at: sent_at,
        router_id: r.id,
        location_id: r.location&.id,
        user_id: r.user&.id
      )
      NotificationMailer.notification_email(n).deliver_later
    end
    RouterStatusNotifier.set(wait: 7.minutes + rand(300)).perform_later
  end
end
