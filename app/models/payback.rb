class Payback < Transfer
  class << self
    def new_from_parameters(date, payer, payee, dollar_amount)
      Payback.new.tap do |payback|
        payback.payee = "Repayment"
        payback.date = date
        payback.dollar_amount_paid = dollar_amount
        payback.person_transfers.new(person: payer, dollar_amount: dollar_amount)
        payback.person_transfers.new(person: payee, dollar_amount: (-dollar_amount))
      end
    end
  end
end
