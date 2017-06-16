class SocialNetworkProfileReader < ApplicationJob
  queue_as :social_networks

  def perform(auth_data, session)
    if auth_data[:provider] == 'without_social' || auth_data[:provider] == 'voucher'
      social_account = SocialAccount.find_or_create_by(client_id: session[:client_id], provider: 'password') do |sa|
        sa.client = Client.find_or_create_by(id: session[:client_id])
        sa.provider = 'password'
        sa.save!
      end
    else
      user_data = SocialAccount.pull_user_data(auth_data)
      social_account = SocialAccount.find_social_account(user_data)
      social_account.update(client_id: session[:client_id])
    end
    NextStep.authorize(social_account, session)
  end
end
