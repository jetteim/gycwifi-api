
require 'rails_helper'

RSpec.describe Client, type: :model do
  context '#social_info' do
    let(:client) { create(:client) }

    it 'collect social account data' do
      social_account = create(:social_account, client: client)
      expect(social_info(social_account)).to eq(client.social_info)
    end

    it 'except password provider' do
      social_account = create(:social_account, provider: 'password', client: client)
      expect(social_info(social_account).merge(provider: nil)).to eq(client.social_info)
    end
    it 'mix 2 not filled social account info' do
      social_account1 = create(:social_account, username: nil, client: client)
      social_account2 = create(:social_account, :nil_info, username: 'user1', client: client)
      expect(social_info(social_account1).merge(username: social_account2.username)).to eq(client.social_info)
    end
  end
end

def social_info(s_a)
  { email: s_a.email,
    gender: s_a.gender,
    image: s_a.image,
    profile: s_a.profile,
    provider: s_a.provider,
    username: s_a.username,
    birthday: s_a.birthday }
end
