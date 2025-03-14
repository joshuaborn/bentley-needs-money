class Reason < ApplicationRecord
  has_many :debts, dependent: :destroy

  accepts_nested_attributes_for :debts

  validates :date, presence: true
  validates_associated :debts
end
