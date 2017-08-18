module Dashboard
  # Rewards Controller
  class RewardsController < ApplicationController
    around_action :skip_bullet, only: :index # gem bullet выдает unused eager loading но это неправда(баг)
    PAGESIZE = 20
    def index
      agent_rewards = policy_scope(AgentReward).includes(user: :promo_code)
      render json: {
        items_count: policy_scope(AgentReward).count,
        items_on_page: PAGESIZE,
        rewards: agent_rewards.page(rewards_params[:page])
                              .per(PAGESIZE)
                              .as_json(include: { user: { include: { promo_code: { only: :code } },
                                                          only: %i[username email] } },
                                       only: %i[amount status_cd]),
        rewards_total: agent_rewards.sum(&:amount),
        rewards_payed: agent_rewards.select(&:payed?).sum(&:amount)
      }
    end

    private

    def rewards_params
      params.permit(:page)
    end
  end
end
