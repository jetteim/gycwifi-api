require 'rails_helper'
RSpec.describe 'Rewards', type: :request do
  let(:agent_reward) { create(:agent_reward, amount: 1) }
  let(:another_agent_reward) { create(:agent_reward, amount: 1) }
  let(:user_with_reward) { agent_reward.agent.user }
  let(:another_user_with_reward) { another_agent_reward.agent.user }
  context 'Index' do
    it 'index agent`s rewards' do
      get my_uri('rewards?page=1'), headers: { 'Authorization' => token(user_with_reward) }
      expect(parsed_response[:rewards]).to include(amount: agent_reward.amount,
                                                   status: agent_reward.status,
                                                   user: { username: agent_reward.order.user.username,
                                                           email: agent_reward.order.user.email },
                                                    promocode: { code: agent_reward.order.user.promo_code.code })
    end
    it 'doesn`t index another agent rewards' do
      get my_uri('rewards?page=1'), headers: { 'Authorization' => token(another_user_with_reward) }
      expect(parsed_response[:rewards]).to be_empty
    end
    context 'paginate 20 per page' do
      before{ create_list(:agent_reward, 20, agent: user_with_reward.agent) }
      it 'index 1st page' do
        get my_uri('rewards?page=1'), headers: { 'Authorization' => token(user_with_reward) }
        expect(parsed_response[:rewards].size).to eq 20
      end
      it 'index 2nd page' do
        get my_uri('rewards?page=2'), headers: { 'Authorization' => token(user_with_reward) }
        expect(parsed_response[:rewards].size).to eq 1
      end
    end
  end
end
