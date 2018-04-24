class CreatePollVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :poll_votes, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :poll_option, type: :uuid
      t.boolean :is_valid

      t.timestamps
    end
  end
end
