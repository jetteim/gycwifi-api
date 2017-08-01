class LocationPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def create?
    l "user #{user.inspect}, create #{resource}, locations count: #{user[:locations_count]}".cyan.bold
    can = user[:power_user]
    if user[:exclusive]
      l 'checking exclusive user role permissions'.cyan
      can ||= (user[:locations_count] < 16)
      l "user #{user.inspect} has reached locations limit".cyan unless can
    end
    if user[:pro]
      l 'checking pro user role permissions'.cyan
      can ||= (user[:locations_count] < 6)
      l "user #{user.inspect} has reached locations limit".cyan unless can
    end
    if user[:active_role] == 'free'
      l 'checking free user role permissions'.cyan
      can ||= (user[:locations_count] < 3)
      l "user #{user.inspect} has reached locations limit".cyan unless can
    end
    log(can)
    can
  end

  def stats?
    show?
  end
  class Scope < Scope
  end
end
