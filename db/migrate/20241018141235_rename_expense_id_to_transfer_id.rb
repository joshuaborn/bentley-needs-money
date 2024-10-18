class RenameExpenseIdToTransferId < ActiveRecord::Migration[7.2]
  def change
    rename_column 'person_transfers', 'expense_id', 'transfer_id'
  end
end
