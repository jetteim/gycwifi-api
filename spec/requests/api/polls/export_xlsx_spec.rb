require 'rails_helper'
RSpec.describe 'Polls xlsx export', type: :request do
  context '/polls/:id/export_to_xlsx' do
    let(:user) { create(:user) }
    let(:poll) { create(:poll, user: user) }
      it 'respond with xlsx' do
        create(:question, poll: poll)
        get my_uri("/polls/#{poll.id}/export_to_xlsx"), headers: {'Authorization' => token(user)}
        expect(response.headers['content-type']).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(response.status).to eq(200)
      end
  end
end
