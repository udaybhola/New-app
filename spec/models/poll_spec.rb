require 'rails_helper'

RSpec.describe Poll, type: :model do
  it { should validate_presence_of :question }

  it "should save with valid attributes" do
    new_poll = build(:poll)
    expect(new_poll).to be_valid

    new_poll.save
    expect(Post.count).to eq 1
  end

  it "should generate slug" do
    new_poll = create(:poll, question: 'Pollution in Delhi')
    expect(new_poll.slug).to eq 'pollution-in-delhi'
  end

  it "should create an activity" do
    new_poll = create(:poll, title: 'Pollution in Delhi')
    activities = new_poll.activities.order('created_at asc')
    expect(activities.first.meta_object).to eq 'Poll'
  end
end
