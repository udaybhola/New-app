class PartyLeaderPosition < ApplicationRecord
  validates :name, :position_hierarchy, presence: true
end
