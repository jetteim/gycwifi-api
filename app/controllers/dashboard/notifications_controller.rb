class Dashboard::NotificationsController < ApplicationController
  # include Skylight::Helpers
  before_action :current_notification, only: %i[show update]
  before_action :all_notifications, only: %i[index unread_count]
  before_action :parse_params
  PAGESIZE = 20

  # instrument_method
  def index
    items_count = @notifications.pluck(:id).count
    notifications = @notifications.order(favorite: :desc, id: :asc).page(@page).per(@itemsOnPage)
    render json: {
      data: {
        itemsOnPage: @itemsOnPage,
        notifications: notifications,
        items_count: items_count
      },
      status: 'ok',
      message: 'Notifications list'
    }
  end

  # instrument_method
  def show
    render json: {
      data: { notification: @notification },
      status: 'ok',
      message: 'notification by ID'
    }
  end

  # instrument_method
  def unread_count
    unread_count = @notifications.where(seen: false).pluck(:id).count
    render json: {
      data: { unread_count: unread_count },
      status: 'ok',
      message: 'notification by ID'
    }
  end

  def update
    @notification.errors.each { |k, _v| return render json: { status: 'error', message: I18n.t("errors.notifications.#{k}") } } unless @notification.update(notification_params)
    render json: success(@notification, 'updated')
  end

  private

  def success(notification, action)
    {
      data: { notification: notification },
      status: 'ok',
      message: I18n.t("errors.notifications.#{action}")
    }
  end

  def parse_params
    @page = @str_prms[:page].to_i || 1
    @page = 1 if @page < 1
    @itemsOnPage = @str_prms[:itemsOnPage] || PAGESIZE
  end

  def current_notification
    @notification = Notification.find_by(id: @str_prms[:id])
    return raise_not_authorized(@notification) unless RedisCache.cached_policy(current_user, @notification, 'show')
  end

  def all_notifications
    return raise_not_authorized(Notification) unless RedisCache.cached_policy(current_user, Notification, 'index')
    @notifications = policy_scope(Notification)
  end

  def notification_params
    params.require(:notification).permit(:seen, :favorite)
  end
end
