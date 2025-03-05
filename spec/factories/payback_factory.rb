FactoryBot.define do
  factory :payback do
    date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    dollar_amount_paid { Faker::Number.decimal(l_digits: 2) }
  end
end
