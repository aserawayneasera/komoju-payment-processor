class PaymentMethod < ApplicationRecord
  belongs_to :customer
  has_many :charges, dependent: :restrict_with_error

  validates :payment_type, presence: true, inclusion: { in: %w[card bank_transfer konbini] }
  validates :last_four, presence: true, format: { with: /\A\d{4}\z/ }
  validates :exp_month, numericality: { in: 1..12 }, allow_nil: true
  validates :exp_year, numericality: { greater_than_or_equal_to: 2024 }, allow_nil: true

  before_save :ensure_single_default

  private

  def ensure_single_default
    if is_default?
      customer.payment_methods.where.not(id: id).update_all(is_default: false)
    end
  end
end
