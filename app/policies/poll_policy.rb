class PollPolicy < ApplicationPolicy
  def create?
    user.exclusive? ||
      (user.pro? && user.polls.count < 11) ||
      (user.free? && user.polls.count < 3) ||
      super
  end
end
