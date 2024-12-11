class CreateSignupRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :signup_requests do |t|
      t.integer :from_id
      t.string :to

      t.timestamps
    end
    add_foreign_key :signup_requests, :people, column: :from_id
  end
end
