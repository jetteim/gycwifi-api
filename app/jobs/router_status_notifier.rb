class RouterStatusNotifier < ApplicationJob
  queue_as :routers

  def perform(router = nil)
    return unless Rails.env.production?
    logger.debug 'starting router status notification check'.red.bold
    (router.blank? ? Router.all.includes(:notifications).includes(:location).includes(:user) : [router]).each do |r|
      # если у роутера status == nil - он ещё не настроен, пропускаем его
      next if r.status.nil?
      notification = r.notifications&.last
      # если последняя нотификация была после даты обновления роутера, отсылать не надо
      next if notification && notification.sent_at > r.updated_at
      # обновляем роутер, создаём нотификацию и отправляем письмо
      r.touch
      NotificationMailer.notification_email(r).deliver_later if notification
      sent_at = DateTime.current
      title = r.status ? "Router #{r.serial} online" : "Router #{r.serial} offline"
      Notification.create(
        title: title,
        details: "#{title} timestamp: #{sent_at}",
        sent_at: sent_at,
        router_id: r.id,
        location_id: r.location&.id,
        user_id: r.user&.id
      )
    end
    RouterStatusNotifier.set(wait: 7.minutes + rand(300)).perform_later
  end
end
