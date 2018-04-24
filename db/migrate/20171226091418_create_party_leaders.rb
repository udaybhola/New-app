class CreatePartyLeaders < ActiveRecord::Migration[5.1]
  def change
    create_table :party_leaders, id: :uuid do |t|
      t.references :party, type: :uuid
      t.references :candidate, type: :uuid
      t.string :post, null: false, default: ''
      t.integer :post_hierarchical_postion, default: 0, null: false

      t.timestamps
    end
  end
end
