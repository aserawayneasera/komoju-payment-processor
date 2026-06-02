FactoryBot.define do
  factory :api_key do
    association :merchant
    token_digest { Digest::SHA256.hexdigest(SecureRandom.hex(32)) }
    name { "test-key" }
  end
end
