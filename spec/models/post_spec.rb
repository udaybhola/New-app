require 'rails_helper'

RSpec.describe Post, type: :model do
  it "should save with valid attributes" do
    new_post = build(:post)
    expect(new_post).to be_valid

    new_post.save
    expect(Post.count).to eq 1
  end

  it "should belong to a category" do
    new_post = create(:post)
    expect(new_post.category).to eq Category.first
  end

  it "should generate slug" do
    new_post = create(:post, title: 'Pollution in Delhi')
    expect(new_post.slug).to eq 'pollution-in-delhi'
  end

  it "can belong to a constituency" do
    constituency = create(:constituency)
    new_post = create(:post)
    new_post.region = constituency
    expect(new_post.region).to eq Constituency.first
  end

  it "can belong to a country_state" do
    country_state = create(:country_state)
    new_post = create(:post)
    new_post.region = country_state
    expect(new_post.region).to eq CountryState.first
  end

  it "should be flaggable" do
    new_post = create(:post)
    expect(new_post.newly_created?).to be_truthy
    expect(new_post.may_report?).to be_truthy
    new_post.report!
    expect(new_post.flagged?).to be_truthy
  end

  it "should not be blockable without being flagged" do
    new_post = create(:post)
    expect(new_post.newly_created?).to be_truthy
    expect(new_post.may_block?).to be_falsey
    expect(new_post.may_approve?).to be_falsey
  end

  it "should be approvable from flagged, also blockable even though approved" do
    new_post = create(:post)
    expect(new_post.newly_created?).to be_truthy
    new_post.report!
    expect(new_post.flagged?).to be_truthy
    new_post.approve!
    expect(new_post.approved?).to be_truthy
    new_post.report!
    new_post.block!
    expect(new_post.blocked?).to be_truthy
  end

  it "can go from approved to blocked directly" do
    new_post = create(:post)
    expect(new_post.newly_created?).to be_truthy
    new_post.report!
    expect(new_post.flagged?).to be_truthy
    new_post.approve!
    new_post.block!
    expect(new_post.blocked?).to be_truthy
  end
end
