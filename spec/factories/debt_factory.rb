FactoryBot.define do
  factory :debt do
    association :ower, factory: :person
    association :owed, factory: :person
    amount { Faker::Number.between(from: 1, to: 100000) }
    reason { association :split, amount: 2 * amount }
  end
end

def create_debt_on_day(**args)
  day = args.delete(:date)
  FactoryBot.build(:debt, **args).tap do |debt|
    debt.reason.date = day
    debt.save!
  end
end
