# в список брендов добавляем всегда видимый бренд с id == 1, а также разрешаем создание всем, кроме бесплатников, ограничивая количество
class BrandPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def create?
    l "user #{user.inspect}, create #{resource}".cyan.bold
    if user[:free]
      log(false)
      return(false)
    end
    can = user[:power_user]
    can ||= (user[:brands_count] < 6) if user[:exclusive]
    can ||= (user[:brands_count] < 3) if user[:pro]
    log(can)
    can
  end

  instrument_method
  def show?
    l "authorize show #{resource.inspect} for user #{user.inspect}".cyan.bold
    can = resource.public || user[:super_user] || (resource.user_id == user[:id])
    can ||= (resource.user_id == user[:user_id]) if user[:can_view_owner_items]
    can ||= (resource.user.user_id == user[:id]) if user[:can_view_child_items]
    log(can)
    can
  end

  instrument_method
  class Scope < Scope
    def resolve
      l "resolving scope #{scope} for user #{user.inspect}".cyan.bold
      return scope.all if user[:super_user]
      scope.where(user_id: user[:id]).or(scope.where(public: true))
    end
  end
end
