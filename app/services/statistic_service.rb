class StatisticService
  include Skylight::Helpers
  BASECOLORS = [
    {
      hover: 'rgba(28,157,237,1)',
      fill: 'rgba(28,157,237,0.8)'
    },
    {
      hover: 'rgba(220,120,220,1)',
      fill: 'rgba(220,120,220,0.8)'
    },
    {
      hover: 'rgba(33,92,99,1)',
      fill: 'rgba(33,92,99,0.8)'
    },
    {
      hover: 'rgba(168,56,88,1)',
      fill: 'rgba(168,56,88,0.8)'
    },
    {
      hover: 'rgba(80,114,153,1)',
      fill: 'rgba(80,114,153,0.8)'
    },
    {
      hover: 'rgba(89,115,38,1)',
      fill: 'rgba(89,115,38,0.8)'
    }
  ].freeze
  DAYS = (1..30).to_a

  # TODO: возвращать labels из метода модели

  def initialize(range:, display_locations:)
    @range = range
    @display_locations = display_locations
  end

  instrument_method
  def raw_new_old_users_pie(locations)
    return unless data = SocialLog.new_old_users_pie(locations, date_format[:start_date], date_format[:end_date])
    chart_data = %w[new_clients returning_clients].map { |val| [val, 0] }.to_h
    chart_data.merge! data
    labels = [I18n.t('stats.new_clients'), I18n.t('stats.returning_clients')]
    {
      labels: labels,
      data: chart_data.values,
      colors: compositeColorsV2
    }
  end

  instrument_method
  def raw_time_pie(locations)
    return unless data = SocialLog.time_pie(locations, date_format[:start_date], date_format[:end_date])
    chart_data = %w[morning afternoon evening night].map { |val| [val, 0] }.to_h
    chart_data.merge! data
    labels = [
      I18n.t('stats.labels.morning'),
      I18n.t('stats.labels.day'),
      I18n.t('stats.labels.evening'),
      I18n.t('stats.labels.night')
    ]
    { labels: labels, data: chart_data.values, colors: compositeColorsV2 }
  end

  instrument_method
  def raw_social_pie(locations)
    return unless data = SocialLog.social_pie(locations, date_format[:start_date], date_format[:end_date])
    chart_data = %w[password google_oauth2 facebook twitter instagram vk].map { |val| [val, 0] }.to_h
    chart_data.merge! data
    labels = [
      I18n.t('stats.labels.password'),
      'Google',
      'Facebook',
      'Twitter',
      'Instagram',
      'VKontakte'
    ]
    { labels: labels, data: chart_data.values, colors: compositeColorsV2 }
  end

  instrument_method
  def raw_gender_pie(locations)
    return unless data = SocialLog.gender_pie(locations, date_format[:start_date], date_format[:end_date])
    chart_data = %w[male female].map { |val| [val, 0] }.to_h
    chart_data.merge! data
    labels = [I18n.t('stats.labels.man'), I18n.t('stats.labels.woman')]
    { labels: labels, data: chart_data.values, colors: compositeColorsV2 }
  end

  instrument_method
  def raw_age_pie(locations)
    return unless data = SocialLog.age_pie(locations, date_format[:start_date], date_format[:end_date])
    keys = %w[age_interval_1 age_interval_2 age_interval_3 age_interval_4 age_interval_5 age_interval_6]
    chart_data = keys.map { |val| [val, 0] }.to_h
    chart_data.merge! data
    labels = [
      I18n.t('stats.labels.less_than_18'),
      '19-25 ' + I18n.t('stats.labels.years'),
      '26-30 ' + I18n.t('stats.labels.years'),
      '31-40 ' + I18n.t('stats.labels.years'),
      '41-55 ' + I18n.t('stats.labels.years'),
      '56 + ' + I18n.t('stats.labels.years')
    ]
    { labels: labels, data: chart_data.values, colors: compositeColorsV2 }
  end

  instrument_method
  def raw_visitors_pie(locations)
    return unless data = SocialLog.visitors_pie(
      locations,
      date_format[:start_date],
      date_format[:end_date]
    )
    chart_data = %w[newcomers loyal resident].map { |val| [val, 0] }.to_h
    chart_data.merge! data
    labels = [
      I18n.t('stats.labels.one_visit'),
      '2-10' + I18n.t('stats.labels.visits'),
      '11+' + I18n.t('stats.labels.visits')
    ]
    { labels: labels, data: chart_data.values, colors: compositeColorsV2 }
  end

  instrument_method
  def raw_new_old_users(locations)
    # TODO: сделать перевод
    return unless users_data = SocialLog.new_users(
      locations,
      date_format[:start_date],
      date_format[:end_date],
      date_format[:interval] || 'day'
    )
    {
      data:   [users_data[:returning_clients], users_data[:new_clients]],
      labels: users_data[:labels],
      series: [I18n.t('stats.returning_clients'), I18n.t('stats.new_clients')],
      colors: compositeColorsV2([{ hover: 'rgba(80,114,153,1)', fill: 'rgba(80,114,153,0.8)' },
                                 { hover: 'rgba(89,115,38,1)', fill: 'rgba(89,115,38,0.8)' }])
    }
  end

  instrument_method
  def compositeColorsV2(src = BASECOLORS)
    result = []
    Array.new(src).each do |color|
      result << {
        fillColor: color[:fill],
        backgroundColor: color[:hover],
        hoverBackgroundColor: color[:hover],
        strokeColor: color[:hover],
        highlightStroke: color[:hover],
        borderColor: color[:hover],
        hoverBorderColor: color[:hover],
        pointBackgroundColor: color[:fill],
        pointHoverBackgroundColor: color[:hover],
        pointBorderColor: '#fff',
        pontHoverBorderColor: '#fff'
      }
    end
    result
  end

  instrument_method
  def date_format
    case @range
    when 'last7days'
      {
        start_date: (DateTime.current - 6.days).beginning_of_day,
        end_date: DateTime.current.end_of_day,
        interval: 'day'
      }
    when 'year'
      {
        start_date: (DateTime.current - 364.days).beginning_of_day,
        end_date: DateTime.current.end_of_day,
        interval: 'day'
      }
    when 'last30days'
      {
        start_date: (DateTime.current - 29.days).beginning_of_day,
        end_date: DateTime.current.end_of_day,
        interval: 'day'
      }
    when 'last90days'
      {
        start_date: (DateTime.current - 89.days).beginning_of_day,
        end_date: DateTime.current.end_of_day,
        interval: 'day'
      }
    else
      {
        start_date: (DateTime.current - 29.days).beginning_of_day,
        end_date: DateTime.current.end_of_day,
        interval: 'day'
      }
    end
  end

  instrument_method
  def total_clients_count
    ClientVisit.select('distinct client_id').where(location: @display_locations).count
  end

  instrument_method
  def last_month_clients_count
    ClientVisit.select('distinct client_id').where(location: @display_locations, updated_at: DateTime.current.months_ago(1).beginning_of_day..DateTime.current.end_of_day).count
  end

  instrument_method
  def last_week_clients_count
    ClientVisit.select('distinct client_id')
               .where(location: @display_locations,
                      updated_at: DateTime.current.weeks_ago(1).beginning_of_day..DateTime.current.end_of_day)
               .count
  end

  instrument_method
  def all_time_connections
    SocialLog.logs_total(@display_locations).count
  end

  instrument_method
  def last_month_connections
    SocialLog.logs_last_month(@display_locations).count
  end

  instrument_method
  def last_week_connections
    SocialLog.logs_last_week(@display_locations).count
  end
end
