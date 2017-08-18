require 'rails_helper'
RSpec.describe 'Rewards', type: :request do
  let(:agent) { create(:agent, :with_promo_code) }
  let(:agent_user) { agent.user }
  let(:user) { create(:user, promo_code: agent.promo_codes.first) }
  let(:order) { create(:order, user: user) }
  let(:user_without_rewards) { create(:agent).user }

  context 'Index' do
    before do
      @agent_reward = create(:agent_reward, amount: 1.0, agent: agent, order: order, status: :unpayed)
    end
    it 'index agent`s rewards' do
      get my_uri('rewards?page=1'), headers: { 'Authorization' => token(agent.user) }
      expect(parsed_response[:rewards][0]).to include(amount: @agent_reward.amount.to_s,
                                                      status_cd: 0,
                                                      user: { username: @agent_reward.user.username,
                                                              email: @agent_reward.user.email,
                                                              promo_code: { code: user.promo_code.code } })
    end
    it 'index total rewards sum' do
      get my_uri('rewards?page=1'), headers: { 'Authorization' => token(agent.user) }
      expect(parsed_response[:rewards_total]).to eq(@agent_reward.amount.to_s)
      expect(parsed_response[:rewards_payed]).to eq(0)
    end
    it 'doesn`t index another agent rewards' do
      get my_uri('rewards?page=1'), headers: { 'Authorization' => token(user_without_rewards) }
      expect(parsed_response[:rewards]).to be_empty
    end
    context 'paginate 20 per page' do
      before { create_list(:agent_reward, 20, agent: agent, amount: 1.0) }
      it 'index 1st page' do
        get my_uri('rewards?page=1'), headers: { 'Authorization' => token(agent.user) }
        expect(parsed_response[:rewards].size).to eq 20
      end
      it 'index 2nd page' do
        get my_uri('rewards?page=2'), headers: { 'Authorization' => token(agent.user) }
        expect(parsed_response[:rewards].size).to eq 1
      end
    end
  end
end
