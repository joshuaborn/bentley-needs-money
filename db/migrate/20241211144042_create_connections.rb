class CreateConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :connections do |t|
      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end
    add_foreign_key :connections, :people, column: :from_id
    add_foreign_key :connections, :people, column: :to_id
  end
end
