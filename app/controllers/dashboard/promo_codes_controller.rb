module Dashboard
  # PromoCodes controller
  class PromoCodesController < ApplicationController
    def index
      authorize PromoCode
      promo_codes = policy_scope(PromoCode).pluck(:code)
      render json: {
        data: {
          promo_codes: promo_codes
        },
        status: 'ok',
        message: 'Promo codes list'
      }
    end

    def create
      authorize PromoCode
      agent = Agent.find_or_create_by(user_id: @current_user[:id])
      promo_code = PromoCode.generate_for_agent(agent)
      render json: {
        data: {
          promo_code: promo_code.code
        },
        status: 'created',
        message: 'Promo code created'
      }
    end

    private

    def promo_code_params
      require(:user).permit(:id)
    end
  end
end
