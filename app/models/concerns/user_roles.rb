module UserRoles #:nodoc:
  extend ActiveSupport::Concern

  ROLES = %w[
    admin agent employee engineer exclusive free manager operator pro
  ].freeze

  included do
    instrument_method
    def role
      type.match(/^(.+)User$/)[1].underscore.to_sym
    end

    instrument_method
    def active_role
      return role unless expiration
      DateTime.current < expiration ? role : :free
    end
  end

  ROLES.each do |name|
    define_method("#{name}?") do
      role == name.to_sym
    end
  end
end
