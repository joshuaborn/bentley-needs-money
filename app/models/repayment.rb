class Repayment < Reason
  validates :debts, length: { is: 1 }
end
