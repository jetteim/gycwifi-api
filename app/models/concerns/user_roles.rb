module UserRoles #:nodoc:
  extend ActiveSupport::Concern

  ROLES = %w[
    admin agent employee engineer free manager operator
  ].freeze

  def role
    role = type.match(/^(.+)User$/)[1].underscore.to_sym
    return role if (%i[pro exclusive].exclude? role) || expiration.nil?
    DateTime.current < expiration ? role : :free
  end

  ROLES.each do |name|
    define_method("#{name}?") do
      role == name.to_sym
    end
  end

  def pro?
    role == :pro || (employee? && user&.pro?)
  end

  def exclusive?
    role == :exclusive || (employee? && user&.exclusive?)
  end

  def super_user?
    admin? || engineer?
  end

  def power_user?
    super_user? || operator? || manager? || agent?
  end

  def can_manage_child_items?
    super_user? || operator?
  end

  def can_create_as_child?
    super_user? || operator?
  end

  def can_view_child_items?
    super_user? || operator? || manager?
  end

  def can_view_peer_items?
    employee?
  end

  def can_view_owner_items?
    employee?
  end
end
