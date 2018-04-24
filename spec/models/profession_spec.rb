require 'rails_helper'

RSpec.describe Profession, type: :model do
  it { should validate_presence_of :name }

  it "should save with valid attributes" do
    new_profession = build(:profession)
    expect(new_profession).to be_valid

    new_profession.save
    expect(Profession.count).to eq 1
  end
end
