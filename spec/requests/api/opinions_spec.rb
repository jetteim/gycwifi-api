require 'rails_helper'
RSpec.describe 'Opinions Api', type: :request do
  context 'CRUD opinions' do
    let(:user) { create(:user) }
    it 'INDEX opinions' do
      opinion = create(:opinion, user: user)
      get my_uri('/opinions'), headers: {'Authorization' => token(user)}
      expect(parsed_response[:data][0]).to include(id: opinion.id, style: opinion.style, message: opinion.message)
    end
    it 'CREATE opininon' do
      opinion = attributes_for(:opinion)
      post my_uri('/opinions'), params: opinion.as_json, headers: {'Authorization' => token(user)}
      expect(Opinion.all.count).to eq(1)
    end
  end
end
