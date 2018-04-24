class AddPreviousVoteToCandidateVote < ActiveRecord::Migration[5.1]
  def change
    add_reference :candidate_votes, :previous_vote, type: :uuid
    add_reference :candidate_votes, :new_vote, type: :uuid
  end
end
