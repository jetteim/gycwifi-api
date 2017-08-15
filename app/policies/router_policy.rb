class RouterPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def create?
    l "user #{user.inspect}, create #{resource} routers count: #{user[:routers_count]}".cyan.bold
    can = user[:power_user] || user[:exclusive]
    can ||= (user[:routers_count] < 16) if user[:pro]
    can ||= (user[:routers_count] < 5) if user[:active_role] == :free || user[:active_role] == "free"
    log(can)
    can
  end
  class Scope < Scope
  end
end
