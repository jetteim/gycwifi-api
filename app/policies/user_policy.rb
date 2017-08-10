class UserPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def update?
    l "authorize update #{resource.inspect} for user #{user.inspect}".cyan.bold
    # потомок не может менять родителя или пиров
    if resource.user_id == user[:user_id]
      log(false)
      return false
    end
    can = user[:super_user] || (resource.user_id == user[:id])
    can ||= (resource.user.user_id == user[:id]) if user[:can_manage_child_items]
    log(can)
    can
  end

  instrument_method
  def destroy?
    l "authorize destroy #{resource.inspect} for user #{user.inspect}".cyan.bold
    # потомок не может удалять родителя или пиров
    if resource.user_id == user[:user_id]
      log(false)
      return false
    end
    can = user[:super_user] || (resource.user_id == user[:id])
    can ||= (resource.user.user_id == user[:id]) if user[:can_manage_child_items]
    log(can)
    can
  end

  instrument_method
  def create?
    # пауэр_юзеры могут создавать по умолчанию всё, остальное в специфических политиках
    l "user #{user.inspect}, create #{resource}".cyan.bold
    can = user[:can_create_normal_users] || user[:can_create_employees]
    log(can)
    can
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

  class Scope < Scope
  end
end
