class RenameExpensesToTransfers < ActiveRecord::Migration[7.2]
  def change
    rename_table 'expenses', 'transfers'
    rename_table 'person_transfers', 'person_transfers'
  end
end
