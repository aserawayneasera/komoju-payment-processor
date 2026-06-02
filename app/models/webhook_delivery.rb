class WebhookDelivery < ApplicationRecord
  belongs_to :webhook_endpoint
  belongs_to :event

  validates :status, inclusion: { in: %w[pending succeeded failed] }
  validates :attempt_count, numericality: { greater_than_or_equal_to: 0 }

  MAX_ATTEMPTS = 3

  def retriable?
    status == "failed" && attempt_count < MAX_ATTEMPTS
  end
end
