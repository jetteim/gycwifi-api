class RouterPackageBuilder < ApplicationJob
  queue_as :routers
  def perform(router)
    router.package if Rails.env.production? || Rails.env.staging?
  end
end
