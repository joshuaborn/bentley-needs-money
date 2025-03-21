class Reason < ApplicationRecord
  has_many :debts, dependent: :destroy

  accepts_nested_attributes_for :debts

  validates :date, presence: true
  validates_associated :debts

  def dollar_amount
    self.amount.to_f / 100
  end

  def dollar_amount=(dollars)
    self.amount = (100 * dollars.to_f).round(0)
  end
end
