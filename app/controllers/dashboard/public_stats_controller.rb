module Dashboard
  class PublicStatsController < StatsController
    skip_before_action :authenticate_user
    ##### Unauthorized methods
    # instrument_method
    def all_connections
      all_connections = RedisCache.use key: 'public_all_connects', lifetime: TOTALS_CACHE_TIMEOUT do
        {
          total: SocialLog.all.count,
          last_month: SocialLog.where(created_at: DateTime.current.months_ago(1).beginning_of_day..DateTime.current.end_of_day).count,
          last_week: SocialLog.where(created_at: DateTime.current.weeks_ago(1).beginning_of_day..DateTime.current.end_of_day).count,
          time: @statistic_service.raw_time_pie(all_locations),
          social: @statistic_service.raw_social_pie(all_locations),
          age: @statistic_service.raw_age_pie(all_locations),
          new_old_users: @statistic_service.raw_new_old_users(all_locations)
        }
      end
      render json: all_connections
    end

    # instrument_method
    def time_pie
      render json: @statistic_service.raw_time_pie(all_locations)
    end

    # instrument_method
    def social_pie
      render json: @statistic_service.raw_social_pie(all_locations)
    end

    # instrument_method
    def age_pie
      render json: @statistic_service.raw_age_pie(all_locations)
    end

    # instrument_method
    def visitors_pie
      render json: @statistic_service.raw_visitors_pie(all_locations)
    end

    private

    # instrument_method
    def all_locations
      @all_locations ||= Location.all.pluck(:id)
    end
  end
end
