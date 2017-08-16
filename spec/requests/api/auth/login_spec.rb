require 'rails_helper'
RSpec.describe 'Registration', type: :request do
  context 'login' do
    before{ @user = create(:user) }
    it 'auth user' do
      get my_uri('auth/password'), params: { email: @user.email,
                                            password: @user.password,
                                            redirectUri: 'dashboard.dev.app'}
      expect(parsed_response).to include(auth: true)
    end
    it 'doesn`t auth user if password incorrect' do
      get my_uri('auth/password'), params: {email: @user.email,
                                            password: "#{@user.password}123",
                                            redirectUri: 'dashboard.dev.app'}
      expect(parsed_response).to include(auth: false)
    end
    it 'returns valid token' do
      get my_uri('auth/password'), params: { email: @user.email,
                                            password: @user.password,
                                            redirectUri: 'dashboard.dev.app'}
      expect(Token.new(parsed_response[:token]).valid?).to eq(true)
    end
  end
end
