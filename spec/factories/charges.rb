FactoryBot.define do
  factory :charge do
    association :merchant
    association :customer
    association :payment_method
    amount { 5000 }
    currency { "JPY" }
    status { "succeeded" }
    description { "Test charge" }
  end
end
