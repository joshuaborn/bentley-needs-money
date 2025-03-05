FactoryBot.define do
  factory :expense do
    payee { Faker::Company.name }
    date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    amount_paid { Faker::Number.between(from: 1, to: 100000) }
  end
end
