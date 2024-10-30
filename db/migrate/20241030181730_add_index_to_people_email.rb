class AddIndexToPeopleEmail < ActiveRecord::Migration[7.2]
  def change
     add_index :people, :email, unique: true
  end
end
