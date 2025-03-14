class Split < Reason
  validates :payee, :amount, :debts, presence: true

  def self.between_two_people(payer, ower, attrs = {})
    Split.new(attrs).tap do |split|
      half_amount = split.amount.to_f / 2
      if half_amount % 1 == 0 then
        loan_amount = half_amount
      elsif rand() <= 0.5 then
        loan_amount = half_amount.floor
      else
        loan_amount = half_amount.ceil
      end
      split.debts.new(
        amount: loan_amount,
        owed: payer,
        ower: ower,
        owed_reconciled: true,
        ower_reconciled: false
      )
    end
  end
end
