class LoginMenuItemPolicy < ApplicationPolicy
  # instrument_method
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def delete?
    true
  end

  class Scope < Scope
    def resolve
      return scope.all if user.super_user?
      scope.where(location_id: Pundit.policy_scope!(user, Location).pluck(:id))
    end
  end
end
