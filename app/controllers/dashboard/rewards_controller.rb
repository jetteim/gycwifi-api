module Dashboard
  # Rewards Controller
  class RewardsController < ApplicationController
    around_action :skip_bullet, only: :index # gem bullet выдает unused eager loading но это неправда(баг)
    PAGESIZE = 20
    def index
      agent_rewards = policy_scope(AgentReward).includes(user: :promo_code).page(rewards_params[:page]).per(PAGESIZE)
      render json: {
        items_count: policy_scope(AgentReward).count,
        itemsOnPage: PAGESIZE,
        rewards: agent_rewards.as_json(include: { user: { include: { promo_code: { only: :code } },
                                                          only: %i[username email] } },
                                       only: %i[amount status_cd])
      }
    end

    private

    def rewards_params
      params.permit(:page)
    end
  end
end
