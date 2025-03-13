class Debt < ApplicationRecord
  belongs_to :ower, class_name: "Person"
  belongs_to :owed, class_name: "Person"
  belongs_to :reason

  validates :amount, comparison: { greater_than: 0 }
end
