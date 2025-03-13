class Debt < ApplicationRecord
  belongs_to :ower, class_name: "Person"
  belongs_to :owed, class_name: "Person"
  belongs_to :reason

  validates :amount, comparison: { greater_than: 0 }
  validates_presence_of :reason

  scope :for_person, ->(person) { where(ower: person).or(where(owed: person)) }
  scope :between_people, ->(first_person, second_person) {
    where(ower: first_person, owed: second_person).or(where(ower: second_person, owed: first_person))
  }

  def dollar_amount
    self.amount.to_f / 100
  end

  def dollar_amount=(dollars)
    self.amount = (100 * dollars.to_f).round(0)
  end

  def dollar_cumulative_sum
    self.cumulative_sum.to_f / 100
  end
end
