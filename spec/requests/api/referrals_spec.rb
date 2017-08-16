require 'rails_helper'
RSpec.describe 'Referrals', type: :request do
  context 'Index' do
    let(:agent) { create(:agent, :with_promo_code) }
    let(:another_agent) { create(:agent).user }
    let(:agent_user) { agent.user }
    before { @referral = create(:user, promo_code: agent.promo_codes[0]) }
    it 'index agent`s referrals' do
      get my_uri('referrals?page=1'),  headers: { 'Authorization' => token(agent_user) }
      expect(parsed_response[:referrals]).to include(username: @referral.username,
                                                      email: @referral.email,
                                                      avatar: @referral.avatar,
                                                      promo_code: {code: @referral.promo_code.code})
    end

    it ' doesn`t index agent`s referrals to another agent' do
      get my_uri('referrals?page=1'),  headers: { 'Authorization' => token(another_agent) }
      expect(parsed_response[:referrals]).to be_empty
    end
    context 'paginate 20 per page' do
      before { create_list(:user, 20, promo_code: agent.promo_codes[0])}
      it 'shows 1st page' do
        get my_uri('referrals?page=1'),  headers: { 'Authorization' => token(agent_user) }
        expect(parsed_response[:referrals].size).to eq 20
      end

      it 'shows 2nd page' do
        get my_uri('referrals?page=2'),  headers: { 'Authorization' => token(agent_user) }
        expect(parsed_response[:referrals].size).to eq 1
      end
    end
  end
end
