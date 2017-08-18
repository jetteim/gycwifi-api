class AgentRewardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(agent: user.agent)
    end
  end
end
