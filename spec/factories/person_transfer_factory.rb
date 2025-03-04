FactoryBot.define do
  factory :person_transfer do
    amount { Faker::Number.between(from: 1, to: 100000) }
    person
  end
end
