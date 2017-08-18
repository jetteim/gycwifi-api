module Dashboard
  # All stats goes to dashboard from here
  # I guess I should separate all statistic by different entity
  class StatsController < ApplicationController
    TOTALS_CACHE_TIMEOUT = 15.minutes

    before_action :check_params, :set_statistic_service
    # Authorized  methods
    instrument_method
    def locations_list
      list = RedisCache.use(key: "locations_list_#{@current_user.id}", lifetime: TOTALS_CACHE_TIMEOUT) do
        {
          data: { locations: @locations.as_json(only: %i[id title address]) },
          status: 'ok',
          message: 'all locations available to current user'
        }
      end
      render json: list
    end

    instrument_method
    def all_connects
      connections = RedisCache.use key: "all_connects#{@current_user.id}", lifetime: TOTALS_CACHE_TIMEOUT do
        { all_time_connections: @statistic_service.all_time_connections,
          from_month: @statistic_service.last_month_connections,
          from_week: @statistic_service.last_week_connections }
      end
      render json: connections
    end

    instrument_method
    def authorizations
      render json:
      {
        data: SocialLog.raw_stats(@display_locations)
          .where(created_at: DateTime.current.weeks_ago(1).beginning_of_day..DateTime.current.end_of_day)
          .group("date_trunc('hour', created_at)")
          .order('date_trunc_hour_created_at')
                       .count(:id)
                       .to_a
      }
    end

    instrument_method
    def new_old_users_pie
      render json: @statistic_service.raw_new_old_users_pie(@display_locations)
    end

    instrument_method
    def time_pie
      render json: @statistic_service.raw_time_pie(@display_locations)
    end

    instrument_method
    def social_pie
      render json: @statistic_service.raw_social_pie(@display_locations)
    end

    instrument_method
    def gender_pie
      render json: @statistic_service.raw_gender_pie(@display_locations)
    end

    instrument_method
    def age_pie
      render json: @statistic_service.raw_age_pie(@display_locations)
    end

    instrument_method
    def visitors_pie
      render json: @statistic_service.raw_visitors_pie(@display_locations)
    end

    instrument_method
    def new_old_users
      render json: @statistic_service.raw_new_old_users(@display_locations)
    end

    instrument_method
    def clients_count
      render json: {
        data: {
          clients_all_time:   @statistic_service.total_clients_count,
          clients_last_month: @statistic_service.last_month_clients_count,
          clients_last_week:  @statistic_service.last_week_clients_count
        },
        status: 'ok',
        message: 'Clients count'
      }
    end

    instrument_method
    def poll_activity
      render json: {
        data: poll_activity_json,
        message: "Poll ##{@str_prms[:id]} statistic",
        status: 'ok'
      }, status: 200
    end

    private

    instrument_method
    def poll_activity_json
      poll = Poll.find(@str_prms[:id])
      activity = PollStatistic::ActivityService.new(poll).call.to_line
      questions = PollStatistic::QuestionService.new(poll).call.to_pie
      result = []
      activity.size.times do |index|
        result << [questions[index], activity[index]]
      end
      result
    end

    instrument_method
    def check_params
      @locations = @current_user.nil? ? nil : policy_scope(Location)
      location_ids = @locations ? @locations.pluck(:id) : nil
      @display_locations = @str_prms[:location_id] ? [@str_prms[:location_id]] : location_ids
      @range = @str_prms[:range] || 'last30days'
    end

    def set_statistic_service
      @statistic_service = StatisticService.new(range: @range, display_locations: @display_locations)
    end

    instrument_method
    def user_locations
      @locations ||= policy_scope(Location)
      @locations.pluck(:id)
    end
  end
end
