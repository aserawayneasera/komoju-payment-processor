FactoryBot.define do
  factory :webhook_endpoint do
    association :merchant
    url { "https://example.com/webhooks" }
    secret_digest { Digest::SHA256.hexdigest(SecureRandom.hex(32)) }
    active { true }
    events { ["*"] }
  end
end
