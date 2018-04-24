require 'rails_helper'

RSpec.describe PartyMembership, type: :model do
  it "should save valid membership" do
    party_membership = build(:party_membership)
    expect(party_membership).to be_valid

    party_membership.save
    expect(PartyMembership.count).to eq 1
  end

  it "should be allow user become a member of a party" do
    user = create(:user)
    user2 = create(:user)
    party = create(:party)

    create(:party_membership, user: user, party: party)
    create(:party_membership, user: user2, party: party)
    expect(user.party_memberships.count).to eq 1
    expect(party.party_memberships.count).to eq 2
  end

  it "should only have one valid membership per user" do
    user = create(:user)
    party1 = create(:party)
    party2 = create(:party)

    create(:party_membership, user: user, party: party1)
    create(:party_membership, user: user, party: party2)

    expect(user.party_memberships.count).to eq 2
    expect(user.party_memberships.valid.count).to eq 1

    expect(party1.party_memberships.count).to eq 1
    expect(party1.party_memberships.valid.count).to eq 0
  end

  it "should create an activity" do
    party = create(:party)
    create(:user)

    membership = create(:party_membership)
    activities = membership.activities.order('created_at asc')

    expect(activities.first.meta_action).to eq 'became a member of'
    expect(activities.first.meta_object).to eq party.title
  end
end
