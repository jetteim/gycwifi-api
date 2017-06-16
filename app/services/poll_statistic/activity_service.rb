module PollStatistic
  class ActivityService < BaseService
    attr_reader :labels, :data, :attempts, :interval, :poll_start

    def call
      time_format = case interval
                    when 'month' then '%Y-%m'
                    when 'day' then '%F'
                    when 'week' then '%F'
                    end
      @data = @poll.questions.pluck(:id).map do |question_id|
        q = { labels: [], data: [[]] }
        attempts_data(question_id).each do |attempt|
          q[:labels] << attempt['period'].to_time.strftime(time_format)
          q[:data][0] << attempt['amount']
          q[:attempts] =  q[:data][0].sum
        end
        q
      end
      self
    end

    def to_line
      autorizations = SocialLog.logs_total(@poll.locations).where('created_at > ?', poll_start).count
      @data.map { |activity| activity.merge!(type: 'line', autorizations: autorizations, name: 'question_activity_line') }
    end

    def interval
      @interval ||= if poll_duration > 3.month.to_i
                      'month'
                    elsif poll_duration > 1.month.to_i
                      'week'
                    else
                      'day'
                    end
    end

    def first_attempt
      @first_attempt ||= @poll.attempts.order(:created_at).first
    end

    def poll_start
      @poll_start ||= first_attempt ? first_attempt.created_at : 1.second.ago
    end

    def poll_duration
      @poll_duration ||= (Time.zone.now - poll_start).to_i
    end

    def attempts_data(question_id)
      sql = "WITH attempts_amount AS
        (
          SELECT
              count(id) AS amount,
              date_trunc('#{interval}', attempts.created_at) AS PERIOD
          FROM attempts
          WHERE attempts.answer_id in (SELECT id FROM answers where question_id = #{question_id})
          GROUP BY PERIOD
        )
        SELECT period,
               CASE
                  WHEN attempts_amount.amount is NULL THEN 0
                  ELSE attempts_amount.amount
               END as amount
        FROM
            (SELECT generate_series(min(period), max(period), '1 #{interval}') AS PERIOD
            FROM attempts_amount) x
        LEFT JOIN attempts_amount
        USING (period)
        ORDER BY period;"
      ActiveRecord::Base.connection.execute(sql).to_a
    end
  end
end
