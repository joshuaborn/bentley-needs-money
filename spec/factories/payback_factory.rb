FactoryBot.define do
  factory :payback do
    date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    amount_paid { Faker::Number.number(digits: 4) }
  end
end
