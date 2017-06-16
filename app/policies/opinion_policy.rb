class OpinionPolicy < ApplicationPolicy
  def create?
    true
  end

  class Scope < Scope
  end
end
