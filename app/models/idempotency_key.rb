class IdempotencyKey < ApplicationRecord
  belongs_to :merchant

  validates :key, presence: true, uniqueness: { scope: :merchant_id }
  validates :request_path, presence: true

  def self.find_or_lock!(merchant:, key:, request_path:)
    record = find_or_initialize_by(merchant: merchant, key: key)
    if record.persisted?
      record
    else
      record.update!(request_path: request_path, locked_at: Time.current)
      record
    end
  end

  def complete!(response_body:, response_code:)
    update!(response_body: response_body, response_code: response_code, locked_at: nil)
  end

  def completed?
    response_code.present? && locked_at.nil?
  end
end
