FactoryBot.define do
  factory :person do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    confirmed_at { DateTime.now - 1.hour }
  end
end
