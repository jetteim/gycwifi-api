module SignInHelper
  def token(user)
    post my_uri('auth/password'), params: { email: user.email,
                                            password: user.password,
                                            redirectUri: 'dashboard.app.dev' }
    JSON.parse(response.body)['token']
  end
end
