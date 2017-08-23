class ApplicationRecord < ActiveRecord::Base
  # include Skylight::Helpers
  self.abstract_class = true

  # instrument_method
  def as_json(options = {})
    super(options)
  end

  # instrument_method
  def to_json(options = {})
    super(options)
  end
end
