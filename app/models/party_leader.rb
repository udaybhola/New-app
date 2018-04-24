class PartyLeader < ApplicationRecord
  belongs_to :party
  belongs_to :candidate
  belongs_to :party_leader_position
end
