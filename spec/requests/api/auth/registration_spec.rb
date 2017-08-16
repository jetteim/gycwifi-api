require 'rails_helper'
RSpec.describe 'Registration', type: :request do
  let(:promocode) { create(:promo_code) }
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }
  let(:username) { Faker::Internet.user_name }
  let(:redirectUri) { 'http://dashboard.dev.app:3232' }
  let(:params) { { email: email,
                   password: password,
                   username: username,
                   redirectUri: redirectUri,
                   code: nil } }
  context 'registration' do
    it 'auth user' do
      get my_uri('auth/password'), params: params
      expect(parsed_response).to include(auth: true)
    end

    it 'creates user' do
      get my_uri('auth/password'), params: params.merge(code: promocode.code)
      expect(User.find_by(email: email)).not_to eq(nil)
    end
  end

  context 'registration with promocode' do
    it 'creates user with promocode' do
      get my_uri('auth/password'), params: params.merge(code: promocode.code)
      expect(User.find_by(email: email).promo_code.code).to eq(promocode.code)
    end
  end
end
