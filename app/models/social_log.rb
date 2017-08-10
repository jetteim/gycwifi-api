# == Schema Information
#
# Table name: social_logs
#
#  id                :integer          not null, primary key
#  social_account_id :integer
#  provider          :string
#  location_id       :integer
#  router_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SocialLog < ApplicationRecord
  # totals_interval = { hour: 'hour', day: 'day', week: 'week', month: 'month' }
  include Skylight::Helpers
  belongs_to :location
  belongs_to :router
  belongs_to :social_account

  # Scopes
  scope :authorizations, ->(locations) {
    select('
    social_logs.id,
    social_logs.social_account_id,
    social_accounts.username,
    social_logs.provider,
    social_logs.router_id,
    routers.serial,
    social_logs.location_id,
    locations.title,
    social_logs.created_at
    ').joins(:location).joins(:router).joins(:social_account).where(location_id: locations)
  }

  scope :raw_stats, ->(locations) { where(location_id: locations) }

  scope :logs_total, ->(locations) { where(location_id: locations) }

  scope :logs_last_month, ->(locations) {
    where(location_id: locations).where(
      created_at: DateTime.current.months_ago(1).beginning_of_day..DateTime.current.end_of_day
    )
  }
  scope :logs_last_week, ->(locations) {
    where(location_id: locations).where(
      created_at: DateTime.current.weeks_ago(1).beginning_of_day..DateTime.current.end_of_day
    )
  }
  instrument_method
  def self.visitors_pie(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day, _interval = 'day')
    return nil if user_locations.blank?
    visits = ClientVisit.where(location: user_locations, updated_at: start_date..end_date).group(:client_id).sum(:visits)
    newcomers = visits.select { |_k, v| v == 1 }
    loyal = visits.select { |_k, v| (v > 1 && v < 11) }
    resident = visits.select { |_k, v| (v > 11) }
    { 'newcomers' => newcomers.count, 'loyal' => loyal.count, 'resident' => resident.count }
  end

  instrument_method
  def self.age_pie(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day, _interval = 'day')
    return nil if user_locations.blank?
    sql = "
    select
      sum (case when age <= 18 then 1 else 0 end) as age_interval_1,
      sum (case when age between 19 and 25 then 1 else 0 end) as age_interval_2,
      sum (case when age between 26 and 30 then 1 else 0 end) as age_interval_3,
      sum (case when age between 31 and 40 then 1 else 0 end) as age_interval_4,
      sum (case when age between 41 and 55 then 1 else 0 end) as age_interval_5,
      sum (case when age >= 56 then 1 else 0 end) as age_interval_6
    from (select
            distinct social_account_id,
            date_part('year',age(make_date(bdate_year, bdate_month, bdate_day))) as age
          from social_logs sl
          join social_accounts sa
            on sl.social_account_id = sa.id
          where location_id in(#{user_locations.join(', ')}) and date_trunc('day', sa.updated_at) between '#{start_date}' and '#{end_date}'
          ) as chart"
    result = ActiveRecord::Base.connection.execute(sql)
    result[0].to_hash
  end

  instrument_method
  def self.gender_pie(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day)
    return nil if user_locations.blank?
    select('social_accounts.id').distinct.joins(:social_account).where(location: user_locations, updated_at: start_date..end_date).group(:gender).count
  end

  instrument_method
  def self.new_old_users_pie(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day)
    return nil if user_locations.blank?
    visits = ClientVisit.where(location: user_locations, updated_at: start_date..end_date).group(:client_id).sum(:visits)
    new_clients = visits.select { |_k, v| v == 1 }
    returning_clients = visits.select { |_k, v| v > 1 }
    { 'new_clients' => new_clients.count, 'returning_clients' => returning_clients.count }
  end

  instrument_method
  def self.time_pie(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day)
    return nil if user_locations.blank?
    sql = "
    select
      sum (case when daytime in (6,7,8,9,10,11) then 1 else 0 end) as morning,
      sum (case when daytime in (12,13,14,15,16,17) then 1 else 0 end) as afternoon,
      sum (case when daytime in (18,19,20,21,22,23) then 1 else 0 end) as evening,
      sum (case when daytime in (0,1,2,3,4,5) then 1 else 0 end) as night
    from( select
            social_account_id,
            date_part('hour',sl.created_at) as daytime
          from social_logs sl
          join social_accounts sa on sl.social_account_id = sa.id
          where location_id in(#{user_locations.join(', ')})
            and date_trunc('day', sl.created_at) between '#{start_date}' and '#{end_date}'
        ) as chart"
    result = ActiveRecord::Base.connection.execute(sql)
    result[0].to_hash
  end

  instrument_method
  def self.social_pie(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day)
    return nil if user_locations.blank?
    joins(:social_account).where(location: user_locations, social_accounts: { created_at: start_date..end_date }).group(:provider).count
  end

  # New users
  def self.new_users(user_locations = nil, start_date = (DateTime.current - 29.days).beginning_of_day, end_date = DateTime.current.end_of_day, interval = 'day')
    return nil if user_locations.blank?
    sql = "
      select
        newusrs.chart_interval,
        ttlusrs.returning as returning_users,
        newusrs.new_users,
        ttlusrs.returning + newusrs.new_users as total
      from (select
          chart_interval,
          count (id) as new_users
        from (select
            distinct cl.id,
            date_trunc('#{interval}', dd)::date as chart_interval
          FROM generate_series ('#{start_date}'::date,'#{end_date}'::date,'1 #{interval}'::interval) dd
          left outer join social_accounts sa on date_trunc('#{interval}', sa.created_at) = date_trunc('#{interval}', dd)
          left outer join clients cl on sa.client_id = cl.id
          join social_logs sl on sa.id = sl.social_account_id
            and location_id in(#{user_locations.join(', ')})
      	  order by chart_interval) as chart
        group by chart_interval
        order by chart_interval
      ) as newusrs join (select
          date_trunc('#{interval}', dd):: date as chart_interval,
          count (distinct cl.id) as returning
        FROM generate_series ('#{start_date}'::date,'#{end_date}'::date,'1 #{interval}'::interval) dd
        left outer join social_logs sl on date_trunc('#{interval}', sl.created_at) = date_trunc('#{interval}', dd)
          and location_id in(#{user_locations.join(', ')})
        join social_accounts sa on sa.id = sl.social_account_id
        left outer join clients cl on date_trunc('#{interval}', cl.created_at) < date_trunc('#{interval}', dd)
          and sa.client_id = cl.id
        group by chart_interval
        order by chart_interval
      ) as ttlusrs on ttlusrs.chart_interval = newusrs.chart_interval"
    @new_clients_per_day = []
    @returning_clients_per_day = []
    @total_clients_per_day = []
    @interval_labels = []
    rows = ActiveRecord::Base.connection.execute(sql)
    rows.each do |row|
      @interval_labels << row['chart_interval'].to_s
      @new_clients_per_day << row['new_users']
      @returning_clients_per_day << row['returning_users']
      @total_clients_per_day << row['total']
    end
    { new_clients: @new_clients_per_day, total_clients: @total_clients_per_day, returning_clients: @returning_clients_per_day, labels: @interval_labels }
  end
end
