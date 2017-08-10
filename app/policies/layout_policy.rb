# в список брендов добавляем всегда видимый бренд с id == 1, а также разрешаем создание всем, кроме бесплатников, ограничивая количество
class LayoutPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def create?
    l "user #{user.inspect}, create #{resource}".cyan.bold
    can = user[:super_user]
    log(can)
    can
  end

  instrument_method
  def show?
    l "authorize show #{resource.inspect} for user #{user.inspect}".cyan.bold
    can = user[:super_user]
    log(can)
    can
  end

  class Scope < Scope
    def resolve
      l "resolving scope #{scope} for user #{user.inspect}".cyan.bold
      scope.all
    end
  end
end
