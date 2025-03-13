FactoryBot.define do
  factory :debt do
    ower_id { 1 }
    owed_id { 1 }
    reason_id { 1 }
    amount { 1 }
    cumulative_sum { 1 }
  end
end
