class Reason < ApplicationRecord
  has_many :debts, dependent: :destroy

  validates_presence_of :date
end
