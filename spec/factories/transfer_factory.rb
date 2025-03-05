FactoryBot.define do
  factory :transfer do
    payee { Faker::Company.name }
    date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    amount_paid { Faker::Number.between(from: 1, to: 100000) }
    person_transfers do
      Array.new(2) { association(:person_transfer) }
    end
  end
end

def create_valid_transfer
  FactoryBot.build(:transfer).tap do |transfer|
    transfer.person_transfers[0].amount = (transfer.amount_paid / 2)
    transfer.person_transfers[1].amount = (transfer.amount_paid / 2) * (-1)
    transfer.save!
  end
end

def create_transfer_between_people(first_person, second_person)
  FactoryBot.build(:transfer).tap do |transfer|
    transfer.person_transfers[0].amount = (transfer.amount_paid / 2)
    transfer.person_transfers[0].person = first_person
    transfer.person_transfers[1].amount = (transfer.amount_paid / 2) * (-1)
    transfer.person_transfers[1].person = second_person
    transfer.save!
  end
end
