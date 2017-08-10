require 'rake'

namespace :routers do
  desc 'Update config packages for all configured routers'
  task rebuild: [:environment] do
    if Rails.env.production?
      thread_group = @thread_group || @thread_group = ThreadGroup.new
      Router.all.each do |router|
        thread_group.add(Thread.new { router.package })
        running = thread_group.list.select(&:alive?)
        running[0].join if running.count > 3
      end
    end
  end
end

namespace :routers do
  desc 'Update config packages for all configured routers'
  task config_update: [:environment] do
    if Rails.env.production?
      thread_group = @thread_group || @thread_group = ThreadGroup.new
      Router.all.each do |router|
        thread_group.add(Thread.new { `sudo --user=admin ssh #{router.ip_name} ':global GYCInstallGetAFile; global GYCInstallAddScript; :global GYCInstallUpdate; $GYCInstallGetAFile "flash/service/update.rsc"; $GYCInstallAddScript "flash/service/update.rsc" $GYCInstallUpdate'` })
        running = thread_group.list.select(&:alive?)
        running[0].join if running.count > 3
      end
    end
  end
end

namespace :routers do
  desc 'Update config packages for all configured routers'
  task os_update: [:environment] do
    if Rails.env.production?
      thread_group = @thread_group || @thread_group = ThreadGroup.new
      Router.all.each do |router|
        thread_group.add(Thread.new { `sudo --user=admin ssh #{router.ip_name} '/system package update install'` })
        running = thread_group.list.select(&:alive?)
        running[0].join if running.count > 3
      end
    end
  end
end

namespace :routers do
  desc 'Rebuild dependencies'
  task insert: [:environment] do
    if Rails.env.staging?
      Location.all.each do |location|
        location.routers.each do |router|
          for ii in 1..6 + (6 * rand(6)).to_i
            social_account = SocialAccount.order('RANDOM()').first
            social_log = SocialLog.new
            social_log.created_at = rand(1.year.ago..Time.now - 2.weeks)
            social_log.created_at = location.created_at if social_log.created_at < location.created_at
            social_log.provider = social_account.provider
            social_log.location_id = location.id
            social_log.router_id = router.id
            social_log.save
            location.increment!(:sms_count)
          end
        end
        location.save
      end
    end
  end
end
