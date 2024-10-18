class AddCumulativeSumToPersonExpense < ActiveRecord::Migration[7.2]
  def change
    add_column :person_transfers, :cumulative_sum, :integer
  end
end
