class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    create_table :linked_accounts do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :access_token

      t.timestamps
    end
  end
end
