class RenameTransactionToExpense < ActiveRecord::Migration[7.2]
  def change
    rename_table :transactions, :expenses
    rename_table :person_transactions, :person_transfers
    rename_column :person_transfers, :transaction_id, :expense_id
  end
end
