FactoryBot.define do
  factory :reason do
    type { "" }
    date { "2025-03-13" }
    payee { "MyString" }
    memo { "MyString" }
    amount { 1 }
  end
end
