class ChangeAmountToInteger < ActiveRecord::Migration[7.2]
  def change
    change_column :expenses, :amount_paid, :integer
    change_column :person_expenses, :amount, :integer
  end
end