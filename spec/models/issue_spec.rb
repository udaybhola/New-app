require 'rails_helper'

RSpec.describe Issue, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }

  it "should save with valid attributes" do
    new_issue = build(:issue)
    expect(new_issue).to be_valid

    new_issue.save
    expect(Post.count).to eq 1
  end

  it "should generate slug" do
    new_issue = create(:issue, title: 'Pollution in Delhi')
    expect(new_issue.slug).to eq 'pollution-in-delhi'
  end

  it "should create an activity" do
    new_issue = create(:issue, title: 'Pollution in Delhi')
    activities = new_issue.activities.order('created_at asc')
    expect(activities.first.meta_object).to eq 'Issue'
  end
end
