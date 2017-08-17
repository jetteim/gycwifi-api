class AgentRewardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(agent_id: user.agent.id)
    end
  end
end
