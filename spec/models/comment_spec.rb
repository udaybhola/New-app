require 'rails_helper'

RSpec.describe Comment, type: :model do
  it "should save with valid attributes" do
    new_comment = build(:comment)
    expect(new_comment).to be_valid

    new_comment.save
    expect(Comment.count).to eq 1
  end

  it "is not valid without a user" do
    new_comment = build(:comment, user: nil)
    expect(new_comment).to_not be_valid

    new_comment.save
    expect(Comment.count).to eq 0
  end

  it "is not valid without a user" do
    new_comment = build(:comment, post: nil)
    expect(new_comment).to_not be_valid

    new_comment.save
    expect(Comment.count).to eq 0
  end

  it "is not valid without text" do
    new_comment = build(:comment, text: nil)
    expect(new_comment).to_not be_valid

    new_comment.save
    expect(Comment.count).to eq 0
  end

  it "can have children_count" do
    parent_comment = create(:comment)
    child_comment = create(:comment, parent: parent_comment)

    expect(Comment.count).to eq 2
    expect(parent_comment.children.count).to eq 1
    expect(parent_comment.children.first).to eq child_comment
    expect(child_comment.parent).to eq parent_comment
  end

  it "should keep track of how many comments it has" do
    parent_comment = create(:comment)
    create(:comment, parent: parent_comment)
    create(:comment, parent: parent_comment)

    expect(parent_comment.comments_count).to eq 2
  end

  it "should create an activity" do
    issue = create(:issue, title: 'An issue with a comment')
    new_comment = create(:comment, post: issue)
    expect(new_comment.activities.count).to eq 2
    activities = new_comment.activities.order('created_at asc')
    expect(activities.first.meta_action).to eq 'commented on'
    expect(activities.first.meta_object).to eq 'Issue'
    expect(activities.first.title).to eq issue.title

    expect(activities.second.meta_action).to eq 'received a comment on'
    expect(activities.second.meta_object).to eq 'Issue'
    expect(activities.second.title).to eq issue.title
  end

  it "should have likable" do
    user1 = create(:user)
    user2 = create(:user)

    new_comment = build(:comment, user: user1)
    expect(new_comment).to be_valid

    new_comment.save
    expect(Comment.count).to eq 1

    new_comment.like(user2)
    new_comment.reload
    expect(new_comment.liked_by_user?(user2.id)).to be_truthy
    expect(new_comment.liked_by_user?(user1.id)).to be_falsey
  end
end
