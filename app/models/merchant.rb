class Merchant < ApplicationRecord
  has_secure_password

  has_many :api_keys, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :charges, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :webhook_endpoints, dependent: :destroy
  has_many :idempotency_keys, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[active inactive suspended] }
end
