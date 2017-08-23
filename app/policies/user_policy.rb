class UserPolicy < ApplicationPolicy
  def create?
    user.pro? || user.exclusive? || super
  end

  def update?
    # потомок не может менять родителя или пиров
    return true if record.id == user.id
    return false if record == user.user || (user.user.users.pluck(:id).include? record.id)
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
