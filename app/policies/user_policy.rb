class UserPolicy < ApplicationPolicy
  def create?
    user.pro? || user.exclusive? || super
  end

  def update?
    # потомок не может менять родителя или пиров
    return false if record.user == user.user
    super
  end

  def destroy?
    update?
  end

  def accounts?
    index?
  end

  def routers?
    index?
  end

  def locations?
    index?
  end

  def brands?
    index?
  end

  def users?
    index?
  end
end
