require 'rails_helper'
RSpec.describe 'PromoCode Api', type: :request do
  context 'FreeUser' do
    let(:user) { create(:free_user) }
    before do
      post my_uri("promo_codes"),
           headers: { 'Authorization' => token(user) }
    end
    it { expect(user.agent).not_to eq(nil) }
    it { expect(user.agent.promo_codes.count).to eq(1) }
  end
end
