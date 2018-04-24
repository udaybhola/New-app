require 'rails_helper'

RSpec.describe Party, type: :model do
  it { should validate_presence_of :abbreviation }
  it { should validate_uniqueness_of :abbreviation }

  it "should save with valid attributes" do
    new_party = build(:party)
    expect(new_party).to be_valid

    new_party.save
    expect(Party.count).to eq 1
  end
end
