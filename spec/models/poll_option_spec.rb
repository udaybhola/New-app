require 'rails_helper'

RSpec.describe PollOption, type: :model do
  it "should save with valid attributes" do
    new_poll_option = build(:poll_option)
    expect(new_poll_option).to be_valid

    new_poll_option.save
    expect(PollOption.count).to eq 4
  end
end
