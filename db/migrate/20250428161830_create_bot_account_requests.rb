class CreateBotAccountRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :bot_account_requests do |t|
      t.string :name
      t.string :email
      t.string :username

      t.timestamps
    end
  end
end
