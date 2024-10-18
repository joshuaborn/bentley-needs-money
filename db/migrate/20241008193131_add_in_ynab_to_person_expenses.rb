class AddInYnabToPersonExpenses < ActiveRecord::Migration[7.2]
  def change
    add_column :person_transfers, :in_ynab, :boolean
  end
end
