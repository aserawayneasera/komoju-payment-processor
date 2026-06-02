FactoryBot.define do
  factory :payment_method do
    association :customer
    payment_type { "card" }
    last_four { "4242" }
    brand { "Visa" }
    exp_month { 12 }
    exp_year { 2027 }
    is_default { true }
  end
end
