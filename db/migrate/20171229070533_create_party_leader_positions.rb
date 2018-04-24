class CreatePartyLeaderPositions < ActiveRecord::Migration[5.1]
  def change
    create_table :party_leader_positions, id: :uuid do |t|
      t.string :name
      t.string :description
      t.integer :position_hierarchy

      t.timestamps
    end
  end
end
