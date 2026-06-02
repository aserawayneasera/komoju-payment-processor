FactoryBot.define do
  factory :event do
    association :merchant
    event_type { "charge.succeeded" }
    payload { { charge_id: 1, amount: 5000 } }
  end
end
