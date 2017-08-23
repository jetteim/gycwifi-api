# в список брендов добавляем всегда видимый бренд с id == 1, а также разрешаем создание всем, кроме бесплатников, ограничивая количество
class LayoutPolicy < ApplicationPolicy
  def create?
    user.super_user?
  end

  def show?
    user.super_user?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
