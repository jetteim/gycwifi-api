class RouterUpdater < ApplicationJob
  queue_as :routers

  def perform(router)
    router.update_router if Rails.env.production?
  end
end
