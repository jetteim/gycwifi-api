require 'rails_helper'
RSpec.describe 'PromoCode Api', type: :request do
  context 'index' do
    let(:agent_with_promocode) { create(:agent, :with_promo_code) }
    it 'index promo codes' do
      get my_uri("promo_codes"),
          headers: { 'Authorization' => token(agent_with_promocode.user) }
       expect(parsed_response[:data][:promo_codes].first).to eq(agent_with_promocode.promo_codes.first.code)
    end
  end

  context 'Create' do
    let(:user) { create(:free_user) }
    before do
      post my_uri("promo_codes"),
           headers: { 'Authorization' => token(user) }
    end
    it { expect(parsed_response[:data][:promo_code]).to eq user.agent.promo_codes.first.code }
    it { expect(user.agent).not_to eq(nil) }
    it { expect(user.agent.promo_codes.count).to eq(1) }
  end
end
