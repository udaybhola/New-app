require 'rails_helper'

RSpec.describe CandidateVote, type: :model do
  it "should save with valid attributes" do
    vote = build(:candidate_vote)
    expect(vote).to be_valid

    vote.save
    expect(CandidateVote.count).to eq 1
  end

  it "should cache count" do
    candidature = create(:candidature)
    user1 = create(:user)
    user2 = create(:user)

    candiate_vote = create(:candidate_vote, candidature: candidature, user: user1)
    create(:candidate_vote, candidature: candidature, user: user2)

    expect(candidature.candidate_votes.count).to eq 2
  end

  it "should be allow user to vote for a candidate" do
    user = create(:user)
    user2 = create(:user)
    candidature = create(:candidature)

    create(:candidate_vote, user: user, candidature: candidature)
    create(:candidate_vote, user: user2, candidature: candidature)
    expect(user.candidate_votes.count).to eq 1
    expect(candidature.candidate_votes.count).to eq 2
  end

  it "should only be unique per election and user" do
    user = create(:user)
    election = create(:election)
    candidature1 = create(:candidature, election: election)
    candidature2 = create(:candidature, election: election)

    create(:candidate_vote, user: user, candidature: candidature1)
    create(:candidate_vote, user: user, candidature: candidature2)

    expect(user.candidate_votes.count).to eq 2
    expect(user.candidate_votes.valid.count).to eq 1

    expect(candidature1.candidate_votes.count).to eq 1
    expect(candidature1.candidate_votes.valid.count).to eq 0
  end

  it "should create an activity" do
    create(:candidature)
    create(:user)

    candidate_vote = create(:candidate_vote)
    activities = candidate_vote.activities.order('created_at asc')
    expect(activities.count).to eq 1
    expect(activities.first.meta_action).to eq 'voted for'
    expect(activities.first.score).to eq 10
  end

  it "should create an activity on cancel vote" do
    create(:candidature)
    create(:user)

    candidate_vote = create(:candidate_vote)

    activities = candidate_vote.activities.order('created_at asc')

    expect(activities.first.meta_action).to eq 'voted for'
    expect(activities.first.score).to eq 10
    expect(candidate_vote.candidature.candidate_votes.valid.count).to eq 1

    canceled_vote = candidate_vote.invalidate_vote
    activities = canceled_vote.activities.order('created_at asc')
    expect(activities.first.meta_action).to eq 'Canceled vote to'
    expect(activities.first.score).to eq(-10)
    expect(candidate_vote.candidature.candidate_votes.valid.count).to eq 0
  end

  it "should create an activity but have zero score for changed vote" do
    candidature = create(:candidature)
    user = create(:user)

    candidate_vote = create(:candidate_vote, user: user, candidature: candidature)
    activities = candidate_vote.activities.order('created_at asc')

    expect(activities.first.meta_action).to eq 'voted for'
    expect(activities.first.score).to eq 10
    candidate_votes = []
    candidate_votes << candidate_vote

    sleep 1.seconds
    candidature2 = create(:candidature, election: candidature.election)
    candidate_vote2 = create(:candidate_vote, user: user, candidature: candidature2, previous_vote: candidate_vote)
    activities = candidate_vote2.activities.order('created_at asc')
    expect(activities.first.score).to eq 0
  end

  it "Voting same candidate should not effect scoring" do
    candidature = create(:candidature)
    user = create(:user)

    candidate_vote = create(:candidate_vote, user: user, candidature: candidature)
    activities = candidate_vote.activities.order('created_at asc')

    expect(activities.first.meta_action).to eq 'voted for'
    expect(activities.first.score).to eq 10

    candidate_vote2 = create(:candidate_vote, user: user, candidature: candidature, previous_vote: candidate_vote)
    activities = candidate_vote2.activities.order('created_at asc')
    expect(activities.first.meta_action).to eq 'changed vote to'
    expect(activities.first.score).to eq 0
  end
end
