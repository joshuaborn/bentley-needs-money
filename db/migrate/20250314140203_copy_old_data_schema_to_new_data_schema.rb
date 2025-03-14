class CopyOldDataSchemaToNewDataSchema < ActiveRecord::Migration[8.0]
  def change
    Payback.all.each do |payback|
      negative_person_transfer = payback.person_transfers.find { |pt| pt.amount < 0 }
      other_person_transfer = payback.person_transfers.find { |pt| pt != negative_person_transfer }
      repayment = Repayment.new(date: payback.date)
      Debt.create!(
        ower: other_person_transfer.person,
        owed: negative_person_transfer.person,
        amount: other_person_transfer.amount,
        reason: repayment
      )
    end
  end
end
