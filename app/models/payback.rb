class Payback < Transfer
  def update(attrs)
    if attrs[:dollar_amount_paid].present?
      new_dollar_amount = attrs[:dollar_amount_paid].to_f
      self.person_transfers.each do |person_transfer|
        if (person_transfer.dollar_amount * new_dollar_amount) < 0 then
          person_transfer.update(dollar_amount: -1 * new_dollar_amount)
        else
          person_transfer.update(dollar_amount: new_dollar_amount)
        end
      end
    end
    super(attrs)
  end

  class << self
    def new_from_parameters(payer, payee, attrs = {})
      Payback.new(attrs).tap do |payback|
        payback.payee = payee.name
        payback.person_transfers.new(person: payer, dollar_amount: attrs[:dollar_amount_paid].to_f)
        payback.person_transfers.new(person: payee, dollar_amount: attrs[:dollar_amount_paid].to_f * -1)
      end
    end
  end
end
