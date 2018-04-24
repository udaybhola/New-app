class CreateCandidateNominations < ActiveRecord::Migration[5.1]
  def change
    create_table :candidate_nominations, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.uuid :party_id
      t.string :age, null: false, default: '12'
      t.string :election_kind, null: false, default: 'assembly'
      t.uuid :country_state_id
      t.uuid :parliament_id
      t.uuid :assembly_id
      t.jsonb :meta, null: false, default: {}

      t.timestamps
    end
  end
end
