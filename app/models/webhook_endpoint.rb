class WebhookEndpoint < ApplicationRecord
  belongs_to :merchant
  has_many :webhook_deliveries, dependent: :destroy

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :secret_digest, presence: true

  def self.generate_for(merchant, url:, events:)
    raw_secret = SecureRandom.hex(32)
    digest = Digest::SHA256.hexdigest(raw_secret)
    endpoint = merchant.webhook_endpoints.create!(
      url: url,
      secret_digest: digest,
      events: events
    )
    [endpoint, raw_secret]
  end

  def listening_for?(event_type)
    events.include?(event_type) || events.include?("*")
  end
end
