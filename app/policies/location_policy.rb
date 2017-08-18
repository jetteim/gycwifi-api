class LocationPolicy < ApplicationPolicy
  def create?
    (user.exclusive? && user.locations.count < 16) ||
      (user.pro? && user.locations.count < 6) ||
      (user.free? && user.locations.count < 3) ||
      super
  end

  def stats?
    show?
  end
end
