class CreateReasons < ActiveRecord::Migration[8.0]
  def change
    create_table :reasons do |t|
      t.string :type
      t.date :date
      t.string :payee
      t.string :memo
      t.integer :amount

      t.timestamps
    end
  end
end
