class AddPhoneNumberToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :phone_number, :string, :null => false, :default => ""
    add_column :users, :firebase_user_id, :string, :null => false, :default => ""
    add_index :users, :firebase_user_id, unique: true
  end
end
