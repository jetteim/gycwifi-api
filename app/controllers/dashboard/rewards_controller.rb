module Dashboard
  class RewardsController < ApplicationController
    PAGESIZE = 20
    def index
      agent_rewards = policy_scope(AgentReward).includes(user: :promo_code).page(rewards_params[:page]).per(PAGESIZE)
      render json: {
        items_count: policy_scope(AgentReward).count,
        itemsOnPage: PAGESIZE,
        rewards: agent_rewards.as_json(include: { user: { include: { promo_code: { only: :code } },
                                                  only: [:username, :email] }},
                                       only: [:amount, :status_cd])
      }
    end

    private

    def rewards_params
      params.permit(:page)
    end
  end
end
