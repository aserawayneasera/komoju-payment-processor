FactoryBot.define do
  factory :refund do
    association :charge
    amount { 1000 }
    status { "succeeded" }
    reason { "Customer request" }
  end
end
