require 'rails_helper'

RSpec.describe Like, type: :model do
  it "should save with valid attributes" do
    build(:like)
  end

  it "should require a user" do
    new_like = build(:like, user: nil)
    expect(new_like).to_not be_valid

    new_like.save
    expect(Like.count).to eq 0
  end

  it "should cache count" do
    post = create(:post)
    comment = create(:comment)
    user1 = create(:user)
    user2 = create(:user)

    Like.create(user: user1, likeable: post)
    Like.create(user: user2, likeable: post)

    expect(post.likes_count).to eq 2

    Like.create(user: user1, likeable: comment)
    Like.create(user: user2, likeable: comment)

    expect(comment.likes_count).to eq 2
  end

  it "should create an activity" do
    poll = create(:poll, question: 'A poll with a comment')
    new_like = create(:like, likeable: poll)
    activities = new_like.activities.order('created_at asc')
    expect(activities.first.meta_action).to eq 'liked'
    expect(activities.first.meta_object).to eq 'Poll'
    expect(activities.first.title).to eq poll.question
  end
end
