FactoryBot.define do
  factory :person_transfer do
    amount { Faker::Number.between(from: 1, to: 100000) }
    person
  end
end

def create_person_transfer_between_people(first_person, second_person, my_amount, this_date = Date.today)
  FactoryBot.build(:transfer).tap do |transfer|
    transfer.date = this_date
    transfer.amount_paid = my_amount * 2
    transfer.person_transfers[0].amount = my_amount
    transfer.person_transfers[0].person = first_person
    transfer.person_transfers[1].amount = (-1) * my_amount
    transfer.person_transfers[1].person = second_person
    transfer.save!
  end.person_transfers[0]
end
