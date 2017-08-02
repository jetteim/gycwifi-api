module PaymentStatuses
  extend ActiveSupport::Concern

  included do
    after_save :update_status
    attr_writer :status
  end

  def status
    statuses.last.try(:code)
  end

  private

  def update_status
    statuses.create!(code: @status) if status != @status
  end
end
