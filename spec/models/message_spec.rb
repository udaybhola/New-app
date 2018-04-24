require 'rails_helper'

RSpec.describe Message, type: :model do
  it "should save with valid attributes" do
    new_message = build(:message)
    expect(new_message).to be_valid

    new_message.save
    expect(Message.count).to eq 1
  end

  it "should require a title" do
    new_message = build(:message, title: nil)
    expect(new_message).to_not be_valid

    new_message.save
    expect(Message.count).to eq 0
  end
end
