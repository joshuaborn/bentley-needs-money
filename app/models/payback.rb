class Payback < Transfer
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
