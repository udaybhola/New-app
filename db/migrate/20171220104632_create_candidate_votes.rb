class CreateCandidateVotes < ActiveRecord::Migration[5.1]
  def change
    drop_table :votes, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :poll_option, type: :uuid

      t.timestamps
    end

    create_table :candidate_votes, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :candidature, type: :uuid
      t.references :election, type: :uuid
      t.boolean :is_valid, null: false, default: true

      t.timestamps
    end
  end
end
