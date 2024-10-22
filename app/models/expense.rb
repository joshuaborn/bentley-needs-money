class Expense < Transfer
  validate :amounts_sum_to_amount_paid

  class << self
    def split_between_two_people(payer, ower, attrs = {})
      expense = Expense.new(attrs)
      half_amount = expense.amount_paid.to_f / 2
      if half_amount % 1 == 0 then
        expense.person_transfers.new(person: payer, amount: half_amount, in_ynab: true)
        expense.person_transfers.new(person: ower, amount: -half_amount, in_ynab: false)
      else
        if rand() <= 0.5 then
          expense.person_transfers.new(person: payer, amount: half_amount.floor, in_ynab: true)
          expense.person_transfers.new(person: ower, amount: -half_amount.ceil, in_ynab: false)
        else
          expense.person_transfers.new(person: payer, amount: half_amount.ceil, in_ynab: true)
          expense.person_transfers.new(person: ower, amount: -half_amount.floor, in_ynab: false)
        end
      end
      expense
    end
    def find_between_two_people(first_person, second_person)
      Expense.joins("JOIN person_transfers AS pe1 ON transfers.id = pe1.transfer_id").
        joins("JOIN person_transfers AS pe2 ON transfers.id = pe2.transfer_id").
        where("pe1.person_id = ? AND pe2.person_id = ?", first_person, second_person)
    end
  end

  private
    def amounts_sum_to_amount_paid
      amount_sum = self.person_transfers.inject(0) do |cumulative_sum, person_transfer|
        cumulative_sum + person_transfer.try(&:amount).to_i.abs
      end
      if amount_sum != self.amount_paid
        self.errors.add(:dollar_amount_paid, "should be the sum of the amounts split between people")
      end
    end
end
