class Customer < ApplicationRecord
  belongs_to :merchant
  has_many :payment_methods, dependent: :destroy
  has_many :charges, dependent: :destroy

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :email, uniqueness: { scope: :merchant_id }
end
