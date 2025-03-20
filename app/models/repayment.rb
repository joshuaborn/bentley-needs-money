class Repayment < Reason
  validates :debts, length: { is: 1 }

  def self.new(repayer, repayee, attrs)
    super({ date: attrs.delete(:date) }).tap do |repayment|
      attrs[:owed_reconciled] = true,
      attrs[:ower_reconciled] = false
      repayment.debts.new({
        owed: repayer,
        ower: repayee,
        **attrs
      })
    end
  end
end
