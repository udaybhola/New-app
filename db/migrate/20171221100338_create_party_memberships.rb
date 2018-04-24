class CreatePartyMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :party_memberships, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :party, type: :uuid
      t.boolean :is_valid, null: false, default: true
      t.timestamps
    end
  end
end
