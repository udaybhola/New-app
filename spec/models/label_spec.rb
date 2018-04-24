require 'rails_helper'

RSpec.describe Label, type: :model do
  it "should save with valid attributes" do
    new_label = build(:label)
    expect(new_label).to be_valid

    new_label.save
    expect(Label.count).to eq 1
  end

  it "should require name" do
    new_label = build(:label, name: nil)
    expect(new_label).to_not be_valid

    new_label.save
    expect(Label.count).to eq 0
  end

  it "can have many candidates" do
    new_label = create(:label)
    new_candidate = build(:candidate)

    new_candidate.label = new_label
    new_candidate.save

    expect(new_label.candidates.count).to eq 1
  end

  it "should add a default color" do
    new_label = create(:label)

    expect(new_label.color.blank?).to be false
  end
end
