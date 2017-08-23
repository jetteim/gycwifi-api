class VoucherPolicy < ApplicationPolicy
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
      return scope if user.super_user?
      scope.where(location_id: Pundit.policy_scope!(user, Location).pluck(:id))
    end
  end
end
