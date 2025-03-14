class Split < Reason
  validates_presence_of :payee, :amount

  def self.between_two_people(payer, ower, attrs = {})
    Split.new(attrs).tap do |split|
      half_amount = split.amount.to_f / 2
      if half_amount % 1 == 0 then
        split.debts.new(owed: payer, ower: ower, amount: half_amount)
      elsif rand() <= 0.5 then
        split.debts.new(owed: payer, ower: ower, amount: half_amount.floor)
      else
        split.debts.new(owed: payer, ower: ower, amount: half_amount.ceil)
      end
    end
  end
end
