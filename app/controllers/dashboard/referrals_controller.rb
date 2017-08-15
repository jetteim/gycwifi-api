module Dashboard
  class ReferralsController < ApplicationController
    PAGESIZE = 20
    def index
      agent = Agent.find(@current_user[:agent_id])
      referrals = agent.referrals.includes(:promo_code).page(referral_params[:page]).per(PAGESIZE)
      render json: {
        items_count: referrals.count,
        itemsOnPage: PAGESIZE,
        referrals: referrals.as_json(include: { promo_code: {only: :code} }, only: [:username, :email, :avatar])
      }
    end

    private

    def referral_params
      params.permit(:page)
    end
  end
end
