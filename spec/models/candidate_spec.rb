require 'rails_helper'

RSpec.describe Candidate, type: :model do
  it "should save with valid attributes" do
    new_candidate = build(:candidate)
    expect(new_candidate).to be_valid

    new_candidate.save
    expect(Candidate.count).to eq 1
  end

  it "have a label" do
    new_label = create(:label, name: 'leader')
    new_candidate = build(:candidate)

    new_candidate.label = new_label
    new_candidate.save

    expect(new_candidate.label).to eq new_label
    expect(new_candidate.label.name).to eq 'leader'
  end
end
