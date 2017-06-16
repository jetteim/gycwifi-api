class NotificationPolicy < ApplicationPolicy
  def create?
    true
  end

  def unread_count?
    index?
  end

  class Scope < Scope
  end
end
