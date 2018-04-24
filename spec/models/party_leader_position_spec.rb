require 'rails_helper'

RSpec.describe PartyLeaderPosition, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:position_hierarchy) }
end
