require 'rails_helper'

RSpec.describe PollVote, type: :model do
  it "should save with valid attributes" do
    vote = build(:poll_vote)
    expect(vote).to be_valid

    vote.save
    expect(PollVote.count).to eq 1
  end

  it "should cache count" do
    poll_option = create(:poll_option)
    user1 = create(:user)
    user2 = create(:user)

    create(:poll_vote, poll_option: poll_option, user: user1)
    create(:poll_vote, poll_option: poll_option, user: user2)

    expect(poll_option.poll_votes_count).to eq 2
  end

  it "should allow user to vote on a poll" do
    user = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    poll_option = create(:poll_option)

    create(:poll_vote, user: user, poll_option: poll_option)
    create(:poll_vote, user: user2, poll_option: poll_option)
    expect(user.poll_votes.count).to eq 1
    expect(poll_option.poll_votes.count).to eq 2
    expect(poll_option.poll.has_user_voted?(user.id)).to be_truthy
    expect(poll_option.poll.has_user_voted?(user2.id)).to be_truthy
    expect(poll_option.poll.has_user_voted?(user3.id)).to be_falsey
  end

  it "should only be unique per poll and user" do
    user = create(:user)
    user1 = create(:user)

    poll = create(:poll)
    poll_option1 = create(:poll_option, poll: poll)
    poll_option2 = create(:poll_option, poll: poll)
    poll_option3 = create(:poll_option, poll: poll)

    poll_vote1 = create(:poll_vote, user: user, poll_option: poll_option1)
    poll_vote11 = create(:poll_vote, user: user1, poll_option: poll_option1)

    poll_vote2 = create(:poll_vote, user: user, poll_option: poll_option2)
    poll_vote22 = create(:poll_vote, user: user1, poll_option: poll_option2)

    poll_vote3 = create(:poll_vote, user: user, poll_option: poll_option3)
    poll_vote33 = create(:poll_vote, user: user1, poll_option: poll_option3)

    expect(poll_vote1.previous_votes.count).to eq 0
    expect(poll_vote2.previous_votes.count).to eq 1
    expect(poll_vote3.previous_votes.count).to eq 2

    expect(user.poll_votes.count).to eq 3
    expect(user.poll_votes.valid.count).to eq 1

    expect(poll_option1.poll_votes.count).to eq 2
    expect(poll_option1.poll_votes.valid.count).to eq 0
  end

  it "should create an activity" do
    new_poll_vote = create(:poll_vote)
    activities = new_poll_vote.activities.order('created_at asc')
    expect(activities.first.meta_action).to eq 'voted for'
    expect(activities.first.title).to eq new_poll_vote.poll.question
  end
end
