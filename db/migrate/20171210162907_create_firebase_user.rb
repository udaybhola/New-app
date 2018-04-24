class CreateFirebaseUser < ActiveRecord::Migration[5.1]
  def change
    create_table :firebase_users, id: :uuid do |t|
      t.string :uid, :null => false, :default => ""
      t.jsonb :firebase_response, :null => false, :default => {}
    end

    add_index :firebase_users, :uid, unique: true
  end
end
