class CopyToNewDataSchema < ActiveRecord::Migration[8.0]
  def up
    Transfer.all.order(date: :asc, created_at: :asc).each do |transfer|
      positive_person_transfer = transfer.person_transfers.find { |pt| pt.amount > 0 }
      negative_person_transfer = transfer.person_transfers.find { |pt| pt.amount < 0 }
      if transfer.type == 'Expense'
        reason = Split.new(
          amount:     transfer.amount_paid,
          created_at: transfer.created_at,
          date:       transfer.date,
          payee:      transfer.payee,
          memo:       transfer.memo
        )
        reason.debts.new(
          amount:          negative_person_transfer.amount * (-1),
          owed:            positive_person_transfer.person,
          owed_reconciled: positive_person_transfer.in_ynab,
          ower:            negative_person_transfer.person,
          ower_reconciled: negative_person_transfer.in_ynab
        )
      elsif transfer.type == 'Payback'
        reason = Repayment.new(
          amount:     negative_person_transfer.amount * (-1),
          created_at: transfer.created_at,
          date:       transfer.date,
          repayee:    negative_person_transfer.person,
          repayer:    positive_person_transfer.person
        )
      end
      reason.save!
    end
  end

  def down
    Reason.delete_all
    Debt.delete_all
  end
end
