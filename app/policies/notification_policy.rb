class NotificationPolicy < ApplicationPolicy
  def create?
    true
  end

  def unread_count?
    index?
  end
end
