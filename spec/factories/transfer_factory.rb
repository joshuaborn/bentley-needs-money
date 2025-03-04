FactoryBot.define do
  factory :transfer do
    payee { Faker::Company.name }
    date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    person_transfers do
      Array.new(2) { association(:person_transfer) }
    end
  end
end
