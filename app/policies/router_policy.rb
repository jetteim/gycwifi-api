class RouterPolicy < ApplicationPolicy
  def create?
    user.exclusive?
    (user.pro? && user.routers.count < 16) ||
      (user.free? && user.routers.count < 5) ||
      super
  end
end
