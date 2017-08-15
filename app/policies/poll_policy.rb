class PollPolicy < ApplicationPolicy
  include Skylight::Helpers

  instrument_method
  def create?
    l "user #{user.inspect}, create #{resource} polls count: #{user[:polls_count]}".cyan.bold
    can = user[:power_user] || user[:exclusive]
    can ||= (user[:polls_count] < 11) if user[:pro]
    can ||= (user[:polls_count] < 3) if user[:active_role] == :free || user[:active_role] == "free"
    log(can)
    can
  end
  class Scope < Scope
  end
end
