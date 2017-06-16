app_path = '/home/gycwifi/api_wifi/api'

# Set the working application directory
# working_directory "/path/to/your/app"
working_directory app_path
# create dirs
FileUtils.mkpath [app_path + '/tmp/pids', app_path + '/tmp/sockets', app_path + '/tmp/packs', app_path + '/tmp/zip', app_path + '/log']
# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid app_path + '/tmp/pids/unicorn.pid'

# Path to logsdle
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path app_path + '/log/unicorn.log'
stdout_path app_path + '/log/unicorn.log'

# Unicorn socket
listen app_path + '/tmp/sockets/unicorn_staging.sock'

# Number of processes
worker_processes 2
# worker_processes 2

# Time-out
timeout 10

# Experimental
preload_app true
# If using ActiveRecord, disconnect (from the database) before forking.
before_fork do |_server, _worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  REDIS.quit if defined?(REDIS)
end

# After forking, restore your ActiveRecord connection.
after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  REDIS = Redis.new
end
# Garbage collection settings.
GC.respond_to?(:copy_on_write_friendly=) &&
  GC.copy_on_write_friendly = true
