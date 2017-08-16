require 'rails_helper'
RSpec.describe 'Private stat', type: :request do
  let(:midnight) { Time.zone.now.beginning_of_day + 1.second }
  let(:birthday) { 20.years.ago }
  let(:account) { create(:social_account, bdate_year: birthday.year, bdate_month: birthday.month, bdate_day: birthday.day, gender: 'male') }
  let(:location) { create(:location, user: account.user) }
  let!(:social_log) do
    create(:social_log,
           updated_at: midnight,
           created_at: midnight,
           provider: 'instagram',
           location: location,
           social_account: account)
  end
  let(:headers) { { 'Authorization' => token(account.user) } }

  context '/stats/time_pie' do
    it 'returns total stats' do
      get my_uri('stats/time_pie'), headers: headers
      expect(parsed_response).to include(labels: [
                                           I18n.t('stats.labels.morning'),
                                           I18n.t('stats.labels.day'),
                                           I18n.t('stats.labels.evening'),
                                           I18n.t('stats.labels.night')
                                         ],
                                         data: [0, 0, 0, 1])
    end
  end

  context '/stats/authorizations' do
    it 'returns authorizations' do
      get my_uri('stats/authorizations'), headers: headers
      expect(parsed_response[:data][0][0].to_time).to eq midnight.beginning_of_hour
    end
  end
  context '/stats/social_pie' do
    it 'returns social pie' do
      get my_uri('/stats/social_pie'), headers: headers
      expect(parsed_response).to include(labels: ['Sms: ', 'Google', 'Facebook', 'Twitter', 'Instagram', 'VKontakte'],
                                         data: [0, 0, 0, 0, 1, 0])
    end
  end
  context 'stats/social_connects' do
    it 'returns social connects' do
      # get my_uri('/stats/social_connects'), headers: headers
      # TODO: does this route exists???
    end
  end
  context '/stats/locations_list' do
    it 'returns users list' do
      get my_uri('/stats/locations_list'), headers: headers
      expect(parsed_response[:data][:locations]).to include(id: location.id,
                                                            title: location.title,
                                                            address: location.address)
    end
  end

  context '/stats/all_connects' do
    it 'returns all connects' do
      get my_uri('/stats/all_connects'), headers: headers
      expect(parsed_response).to include(all_time_connections: 1, from_month: 1, from_week: 1)
    end
  end

  context '/stats/new_old_users_pie' do
    it 'returns new users and users that came back' do
      get my_uri('/stats/new_old_users_pie'), headers: headers
      expect(parsed_response).to include(labels: [I18n.t('stats.new_clients'), I18n.t('stats.returning_clients')], data: [1, 0])
    end
  end

  context '/stats/visitors_pie' do
    it 'returns visitors pie' do
      get my_uri('/stats/visitors_pie'), headers: headers
      expect(parsed_response).to include(labels: [I18n.t('stats.labels.one_visit'),
                                                  '2-10' + I18n.t('stats.labels.visits'),
                                                  '11+' + I18n.t('stats.labels.visits')], data: [1, 0, 0])
    end
  end

  context '/stats/questionpie' do
    it 'returns questionpie' do
      # get my_uri('/stats/questionpie'), headers: headers
      # TODO: does this route exists?
    end
  end

  context '/stats/age_pie' do
    it 'returns age_pie' do
      get my_uri('/stats/age_pie'), headers: headers
      expect(parsed_response).to include(data: [0, 1, 0, 0, 0, 0], labels: [
                                           I18n.t('stats.labels.less_than_18'),
                                           '19-25 ' + I18n.t('stats.labels.years'),
                                           '26-30 ' + I18n.t('stats.labels.years'),
                                           '31-40 ' + I18n.t('stats.labels.years'),
                                           '41-55 ' + I18n.t('stats.labels.years'),
                                           '56 + ' + I18n.t('stats.labels.years')
                                         ])
    end
  end

  context '/stats/gender_pie' do
    it 'returns gender_pie' do
      get my_uri('/stats/gender_pie'), headers: headers
      expect(parsed_response).to include(data: [1, 0], labels: [I18n.t('stats.labels.man'), I18n.t('stats.labels.woman')])
    end
  end

  context '/stats/new_old_users' do
    it 'returns new_old_users' do
      get my_uri('/stats/new_old_users'), headers: headers
      expect(parsed_response).to include(data: [[0], [1]],
                                         labels: [Time.zone.now.strftime('%F')],
                                         series: [I18n.t('stats.returning_clients'), I18n.t('stats.new_clients')])
    end
  end

  context '/stats/clients_count' do
    it 'returns clients_count' do
      get my_uri('/stats/clients_count'), headers: headers
      expect(parsed_response).to include(data: { clients_all_time: 1, clients_last_month: 1, clients_last_week: 1 })
    end
  end
end
