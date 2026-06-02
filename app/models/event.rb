class Event < ApplicationRecord
  belongs_to :merchant
  has_many :webhook_deliveries, dependent: :destroy

  validates :event_type, presence: true
  validates :payload, presence: true

  TYPES = %w[
    charge.succeeded
    charge.failed
    charge.refunded
    refund.created
    refund.succeeded
    payment_method.created
    customer.created
  ].freeze

  validates :event_type, inclusion: { in: TYPES }
end
