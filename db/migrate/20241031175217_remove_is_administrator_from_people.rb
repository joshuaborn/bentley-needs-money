class RemoveIsAdministratorFromPeople < ActiveRecord::Migration[7.2]
  def change
    remove_column :people, :is_administrator
  end
end
