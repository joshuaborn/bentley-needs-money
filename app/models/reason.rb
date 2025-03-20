class Reason < ApplicationRecord
  has_many :debts, dependent: :destroy
  has_many :owers, through: :debts
  has_many :oweds, through: :debts

  accepts_nested_attributes_for :debts, reject_if: :new_record?

  validates :date, :dollar_amount, presence: true
  validates_associated :debts

  def people
    self.owers | self.oweds
  end

  def dollar_amount
    self.amount.to_f / 100
  end

  def dollar_amount=(dollars)
    self.amount = (100 * dollars.to_f).round(0)
  end
end
