require 'rails_helper'

RSpec.describe Constituency, type: :model do
  it "should save with valid attributes" do
    new_constituency = build(:constituency)
    expect(new_constituency).to be_valid

    new_constituency.save
    expect(Constituency.count).to eq 1
  end

  it "is not valid without a name" do
    new_constituency = build(:constituency, name: nil)
    expect(new_constituency).to_not be_valid

    new_constituency.save
    expect(Constituency.count).to eq 0
  end

  it "should belong to a state" do
    new_constituency = create(:constituency)

    expect(new_constituency.country_state).to eq CountryState.first
  end

  it "should save kind" do
    parliamentary_constituency = create(:constituency, name: 'Hyderabad')
    assembly_constituency = create(:constituency, name: 'Secunderabad', parent: parliamentary_constituency)

    expect(parliamentary_constituency.kind).to eq 'parliamentary'
    expect(assembly_constituency.kind).to eq 'assembly'
  end

  it "should know its current election" do
    assem_constituency = create(:constituency)
    parliamentary_constituency = create(:constituency)
    parliamentary_constituency.children << assem_constituency

    expect(assem_constituency.is_assembly?).to be_truthy
    expect(assem_constituency.is_parliament?).to be_falsey

    expect(parliamentary_constituency.is_parliament?).to be_truthy
    expect(parliamentary_constituency.is_assembly?).to be_falsey

    assembly_election_past = Election.create!(
      country_state: assem_constituency.country_state,
      kind: Election::KIND_ASSEMBLY,
      starts_at: 200.days.ago,
      ends_at: 100.days.ago
    )

    assembly_election_current = Election.create!(
      country_state: assem_constituency.country_state,
      kind: Election::KIND_ASSEMBLY,
      starts_at: 200.days.ago,
      ends_at: 100.days.from_now
    )

    assembly_election_future = Election.create!(
      country_state: assem_constituency.country_state,
      kind: Election::KIND_ASSEMBLY,
      starts_at: 200.days.from_now,
      ends_at: 300.days.from_now
    )

    parliamentary_election_past = Election.create!(
      kind: Election::KIND_PARLIAMENT,
      starts_at: 200.days.ago,
      ends_at: 100.days.ago
    )

    parliamentary_election_current = Election.create!(
      kind: Election::KIND_PARLIAMENT,
      starts_at: 200.days.ago,
      ends_at: 100.days.from_now
    )

    parliamentary_election_future = Election.create!(
      kind: Election::KIND_PARLIAMENT,
      starts_at: 200.days.from_now,
      ends_at: 300.days.from_now
    )

    ## changing to latest created election
    expect(assem_constituency.current_election).to eq assembly_election_future
    expect(parliamentary_constituency.current_election).to eq parliamentary_election_future
  end
end
