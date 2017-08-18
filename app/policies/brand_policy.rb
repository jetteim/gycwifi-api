# в список брендов добавляем всегда видимый бренд с id == 1, а также разрешаем создание всем, кроме бесплатников, ограничивая количество
class BrandPolicy < ApplicationPolicy
  def create?
    (user.exclusive? && user.brands.count < 6) ||
      (user.pro? && user.brands.count < 3) ||
      super
  end

  def show?
    record.public || super
  end

  class Scope < Scope
    def resolve
      return scope if user.super_user?
      scope.where(user: user).or(scope.where(public: true))
    end
  end
end
