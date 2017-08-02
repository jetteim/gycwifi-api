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
  include Skylight::Helpers
  attr_reader :user, :resource

  def initialize(user, resource)
    @user = RedisCache.cached_user(user[:id])
    @resource = resource
  end

  instrument_method
  def index?
    l "authorize index #{resource} for user #{user[:id]}".cyan.bold

    can = user[:super_user]
    can ||= resource.where(user: user[:id]).count
    can ||= user[:can_view_owner_items] && resource.where(user: user[:user_id]).count
    can ||= user[:can_view_child_items] && resource.where(user: User.where(user_id: user[:id]).pluck(:id)).count
    log(can)
    can
  end

  instrument_method
  def show?
    l "authorize show #{resource} for user #{user[:id]}".cyan.bold
    can = user[:super_user] || (resource.user_id == user[:id])
    can ||= user[:can_view_owner_items] && (resource.user.id == user[:user_id])
    can ||= user[:can_view_child_items] && (resource.user.user.id == user[:id])
    log(can)
    can
  end

  instrument_method
  def create?
    # пауэр_юзеры могут создавать по умолчанию всё
    # в наследуемых политиках надо переопределять этот метод
    l "authorize create #{resource} for user #{user[:id]}".cyan.bold
    w "Attention! application policy method called for create #{resource}".red.bold
    w 'you should use object policy instead'.red.bold
    can = user[:power_user]
    log(can)
    can
  end

  def new?
    create?
  end

  instrument_method
  def update?
    l "authorize update #{resource} for user #{user[:id]}".cyan.bold
    can = user[:super_user] || (resource.user_id == user[:id])
    can ||= user[:can_manage_child_items] && resource.user.user.id == user[:id]
    log(can)
    can
  end

  def edit?
    update?
  end

  instrument_method
  def destroy?
    l "authorize delete #{resource.inspect} for user #{user.inspect}".cyan.bold
    can = user[:super_user] || (resource.user_id == user[:id])
    can ||= user[:can_manage_child_items] && resource.user.user.id == user[:id]
    log(can)
    can
  end

  def scope
    Pundit.policy_scope!(user, resource.class)
  end

  protected

  def l(s)
    Rails.logger.debug(s)
  end

  def i(s)
    Rails.logger.info(s)
  end

  def w(s)
    Rails.logger.warn(s)
  end

  def log(can)
    s = 'can' if can
    s = 'cannot' unless can
    l "user #{user.inspect} #{s} access resource #{resource.inspect}".cyan.bold
  end

  class Scope
    include Skylight::Helpers
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = RedisCache.cached_user(user[:id])
      @scope = scope
    end

    def resolve
      l "resolving scope #{scope} for user #{user.inspect}".cyan.bold
      return scope.all if user[:super_user]
      result = scope.where(user: user[:id])
      result = result.or(scope.where(user: user[:user_id])) if user[:can_view_owner_items]
      result = result.or(scope.where(user: User.find_by(user: user[:user_id]))) if user[:can_view_peer_items]
      result = result.or(scope.where(user: User.where(user: user[:id]).pluck(:id))) if user[:can_view_child_items]
      result
    end

    def l(s)
      Rails.logger.debug(s)
    end

    def i(s)
      Rails.logger.info(s)
    end

    def w(s)
      Rails.logger.warn(s)
    end
  end
end
