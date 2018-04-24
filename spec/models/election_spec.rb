require 'rails_helper'

RSpec.describe Election, type: :model do
  it "should save with valid attributes" do
    new_election = build(:election)
    expect(new_election).to be_valid

    new_election.save
    expect(Election.count).to eq 1
  end
end
