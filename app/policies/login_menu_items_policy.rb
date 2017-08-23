class LoginMenuItemPolicy < ApplicationPolicy
  instrument_method
  def index?
    true
  end

  class Scope < Scope
    def resolve
      return scope if user.super_user?
      scope.where(location_id: Pundit.policy_scope!(user, Location).pluck(:id))
    end
  end
end
