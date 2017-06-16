require 'rails_helper'
RSpec.describe 'Public stat', type: :request do
  # data depends on labels; labels predefined in stats_controller
  before do
    midnight = Time.zone.now.beginning_of_day + 1.second
    birthday = 20.years.ago
    account = create(:social_account, bdate_year: birthday.year, bdate_month: birthday.month, bdate_day: birthday.day)
    create(:social_log, updated_at: midnight, created_at: midnight, provider: 'instagram', social_account: account)
  end

  context '/public_stats/totals' do
    it 'return total stats' do
      get my_uri('public_stats/totals')
      expect(parsed_response).to include(total: 1, last_month: 1, last_week: 1)
      expect(parsed_response[:time]).to include(labels: ['Morning 06:00 - 11:59', 'Day 12:00 - 17:59', 'Evening 18:00 - 23:59', 'Night 00:00 - 05:59'], data: [0, 0, 0, 1])
      expect(parsed_response[:social]).to include(labels:  [I18n.t('stats.labels.password'),
                                                            'Google',
                                                            'Facebook',
                                                            'Twitter',
                                                            'Instagram',
                                                            'VKontakte'],
                                                  data: [0, 0, 0, 0, 1, 0])
    end
  end
  context '/public_stats/time' do
    it 'return time stats' do
      get my_uri('public_stats/time')
      expect(parsed_response).to include(labels: [I18n.t('stats.labels.morning'),
                                                  I18n.t('stats.labels.day'),
                                                  I18n.t('stats.labels.evening'),
                                                  I18n.t('stats.labels.night')], data: [0, 0, 0, 1])
    end
  end
  context '/public_stats/social' do
    it 'return time stats' do
      get my_uri('public_stats/social')
      expect(parsed_response).to include(labels: [I18n.t('stats.labels.password'),
                                                  'Google',
                                                  'Facebook',
                                                  'Twitter',
                                                  'Instagram',
                                                  'VKontakte'], data: [0, 0, 0, 0, 1, 0])
    end
  end
  context '/public_stats/age' do
    it 'return time stats' do
      get my_uri('public_stats/age')
      expect(parsed_response).to include(labels: [I18n.t('stats.labels.less_than_18'),
                                                  '19-25 ' + I18n.t('stats.labels.years'),
                                                  '26-30 ' + I18n.t('stats.labels.years'),
                                                  '31-40 ' + I18n.t('stats.labels.years'),
                                                  '41-55 ' + I18n.t('stats.labels.years'),
                                                  '56 + ' + I18n.t('stats.labels.years')],
                                         data: [0, 1, 0, 0, 0, 0])
    end
  end

  context '/public_stats/visitors' do
    it 'return time stats' do
      get my_uri('public_stats/visitors')
      expect(parsed_response).to include(labels: [I18n.t('stats.labels.one_visit'),
                                                  '2-10' + I18n.t('stats.labels.visits'),
                                                  '11+' + I18n.t('stats.labels.visits')],
                                         data: [1, 0, 0])
    end
  end
end
