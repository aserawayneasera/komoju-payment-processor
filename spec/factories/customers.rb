FactoryBot.define do
  factory :customer do
    association :merchant
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number }
  end
end
