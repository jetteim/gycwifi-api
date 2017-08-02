class VoucherPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def index?
    l "authorize index #{resource} for user #{user.inspect}".cyan.bold
    can = true
    log(can)
    can
  end

  instrument_method
  def show?
    l "authorize show #{resource.inspect} for user #{user.inspect}".cyan.bold
    can = RedisCache.cached_policy(user, resource.location, 'show')
    log(can)
    can
  end

  instrument_method
  def create?
    # пауэр_юзеры могут создавать по умолчанию всё
    # в наследуемых политиках надо переопределять этот метод
    l "authorize create #{resource} for user #{user.inspect}".cyan.bold
    can = user[:power_user]
    log(can)
    can
  end

  def new?
    create?
  end

  instrument_method
  def update?
    l "authorize update #{resource.inspect} for user #{user.inspect}".cyan.bold
    can = RedisCache.cached_policy(user, resource.location, 'update')
    log(can)
    can
  end

  def edit?
    update?
  end

  instrument_method
  def destroy?
    l "authorize delete #{resource.inspect} for user #{user.inspect}".cyan.bold
    can = RedisCache.cached_policy(user, resource.location, 'update')
    log(can)
    can
  end

  class Scope < Scope
    include Pundit
    def resolve
      l "resolving scope #{scope} for user #{user.inspect}".cyan.bold
      return scope.all if user[:super_user]
      result = scope.where(location_id: Pundit.policy_scope!(user, Location).pluck(:id))
      result
    end
  end
end
