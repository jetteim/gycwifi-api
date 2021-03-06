class PromoCodePolicy < ApplicationPolicy
  def create?
    true # все могут создавать промокоды
  end

  def index?
    true # все могут видеть промокоды
  end

  class Scope < Scope
    def resolve
      scope.where(agent_id: user.agent_id)
    end
  end
end
