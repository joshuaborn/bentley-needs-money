class AddReconciledAttributesToDebts < ActiveRecord::Migration[8.0]
  def change
    add_column :debts, :ower_reconciled, :boolean
    add_column :debts, :owed_reconciled, :boolean
  end
end
