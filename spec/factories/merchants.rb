FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    status { "active" }
  end
end
