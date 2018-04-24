require 'rails_helper'

RSpec.describe Religion, type: :model do
  it { should validate_presence_of :name }

  it "should save with valid attributes" do
    new_religion = build(:religion)
    expect(new_religion).to be_valid

    new_religion.save
    expect(Religion.count).to eq 1
  end
end
