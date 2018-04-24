require 'rails_helper'

RSpec.describe Attachment, type: :model do
  it "should save with valid attributes" do
    new_attachment = build(:attachment)
    expect(new_attachment).to be_valid

    new_attachment.save
    expect(Attachment.count).to eq 1
  end
end
