class Repayment < Reason
  DEBT_ATTRIBUTES_MAPPING = {
    repayer: :owed,
    repayee: :ower,
    amount: :amount
  }

  validates :debts, length: { is: 1 }

  def self.new(attrs)
    super(attrs.except(*DEBT_ATTRIBUTES_MAPPING.keys)).tap do |repayment|
      debt_attributes = attrs.slice(*DEBT_ATTRIBUTES_MAPPING.keys).transform_keys do |key|
       DEBT_ATTRIBUTES_MAPPING[key]
      end
      repayment.debts.new(debt_attributes)
    end
  end
end
