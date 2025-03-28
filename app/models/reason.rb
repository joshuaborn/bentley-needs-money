class Reason < ApplicationRecord
  has_many :debts, dependent: :destroy
  has_many :owers, through: :debts
  has_many :oweds, through: :debts

  accepts_nested_attributes_for :debts, reject_if: :new_record?

  validates :date, presence: true
  validates_associated :debts

  def people
    self.owers | self.oweds
  end
end
