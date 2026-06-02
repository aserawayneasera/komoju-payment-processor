class Refund < ApplicationRecord
  belongs_to :charge

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending succeeded failed] }
  validate :amount_within_refundable_balance

  private

  def amount_within_refundable_balance
    return unless amount && charge
    pending_and_succeeded = charge.refunds.where(status: %w[pending succeeded]).where.not(id: id).sum(:amount)
    if amount > charge.amount - pending_and_succeeded
      errors.add(:amount, "exceeds refundable balance")
    end
  end
end
