FactoryBot.define do
  factory :expense do
    payee { Faker::Company.name }
    date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    amount_paid { Faker::Number.between(from: 1, to: 100000) }
  end
end

def create_expense_between_people(first_person, second_person)
  FactoryBot.build(:expense).tap do |expense|
    expense.person_transfers.new({
      amount: expense.amount_paid / 2,
      person: first_person
    })
    expense.person_transfers.new({
      amount: (expense.amount_paid / 2) * (-1),
      person: second_person
    })
    expense.save!
  end
end
