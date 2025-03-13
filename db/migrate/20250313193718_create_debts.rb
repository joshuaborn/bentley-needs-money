class CreateDebts < ActiveRecord::Migration[8.0]
  def change
    create_table :debts do |t|
      t.integer :ower_id
      t.integer :owed_id
      t.integer :reason_id
      t.integer :amount
      t.integer :cumulative_sum

      t.timestamps
    end
  end
end
