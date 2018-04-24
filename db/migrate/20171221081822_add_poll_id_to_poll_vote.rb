class AddPollIdToPollVote < ActiveRecord::Migration[5.1]
  def change
    add_reference :poll_votes, :poll, type: :uuid

    reversible do |change|
      change.up do
        change_column :poll_votes, :is_valid, :boolean, null: false, default: true
      end
    end
  end
end
