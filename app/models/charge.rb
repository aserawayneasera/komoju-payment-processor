class Charge < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  belongs_to :payment_method
  has_many :refunds, dependent: :destroy
  has_many :events, as: :chargeable, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[JPY USD EUR GBP] }
  validates :status, inclusion: { in: %w[pending succeeded failed refunded] }

  validate :customer_belongs_to_merchant
  validate :payment_method_belongs_to_customer

  def refundable_amount
    amount - refunds.where(status: %w[pending succeeded]).sum(:amount)
  end

  private

  def customer_belongs_to_merchant
    if customer && customer.merchant_id != merchant_id
      errors.add(:customer, "does not belong to this merchant")
    end
  end

  def payment_method_belongs_to_customer
    if payment_method && payment_method.customer_id != customer_id
      errors.add(:payment_method, "does not belong to this customer")
    end
  end
end
