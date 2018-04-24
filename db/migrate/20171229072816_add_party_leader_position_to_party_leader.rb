class AddPartyLeaderPositionToPartyLeader < ActiveRecord::Migration[5.1]
  def change
    add_reference :party_leaders, :party_leader_position, type: :uuid
  end
end
