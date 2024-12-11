class CreateConnectionRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :connection_requests do |t|
      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end
    add_foreign_key :connection_requests, :people, column: :from_id
    add_foreign_key :connection_requests, :people, column: :to_id
  end
end
