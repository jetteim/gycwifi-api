class LogBeforeTimeout
  def initialize(app)
    @app = app
  end

  def call(env)
    thr = Thread.new do
      timeout = Rails.env == 'development' ? 10000 : 9.5
      sleep(timeout) # set this to Unicorn timeout - 1
      unless Thread.current[:done]
        path = env['PATH_INFO']
        (qs = env['QUERY_STRING']) && (path = "#{path}?#{qs}")
        Rails.logger.fatal '---------------------------------------------------------------'.red.bold
        Rails.logger.fatal "the request from #{path} has 1 second before unicorn worker timeout".red.bold
        Rails.logger.fatal '---------------------------------------------------------------'.red.bold
        Rails.logger.fatal "environment: #{env.inspect}".red.bold
        Rails.logger.fatal '---------------------------------------------------------------'.red.bold
      end
    end
    @app.call(env)
  ensure
    thr[:done] = true
    thr.run
  end
end
