# в корневом классе прописаны фундаментальные свойства
# - админу можно делать всё
# - инженер может делать всё, но не может изменить/удалить админа
# - владельцу можно делать всё со своими объектами
# - количественные ограничения
# при необходимости наследуемся для конкретного контроллера, в том числе для
# - поддержки авторизации других методов
# - какие атрибуты кому можно менять
# - кто может поменять владельца объекта
# - кто кого может редактировать

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    #все могут видеть, разница лишь в том что юзеры видят, поэтому всегда  true(TODO:  удалить все остальное, кроме true)
    user.super_user? ||
      record.exists?(user: user)||
      (user.can_view_owner_items? && record.exists?(user: user.user)) ||
      (user.can_view_child_items? && record.exists?(user: User.where(user: user).pluck(:id))) || true
  end

  def show?
    user.super_user? || record.user == user ||
      (user.can_view_owner_items? && record.user == user.user) ||
      (user.can_view_child_items? && record.user.user == user)
  end

  def create?
    # пауэр_юзеры могут создавать по умолчанию всё
    # в наследуемых политиках надо вызывать super
    user.power_user?
  end

  def new?
    create?
  end

  def update?
    user.super_user? || record.user == user ||
      (user.can_manage_child_items? && record.user.user == user)
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope if user.super_user?
      result = scope.where(user: user)
      result = result.or(scope.where(user: user.user)) if user.can_view_owner_items?
      result = result.or(scope.where(user: User.find_by(user: user.user))) if user.can_view_peer_items?
      result = result.or(scope.where(user: User.where(user: user).pluck(:id))) if user.can_view_child_items?
      result
    end
  end
end
