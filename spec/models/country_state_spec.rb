require 'rails_helper'

RSpec.describe CountryState, type: :model do
  it "should save with valid attributes" do
    new_state = build(:country_state)
    expect(new_state).to be_valid

    new_state.save
    expect(CountryState.count).to eq 1
  end

  it "is not valid without a name" do
    new_state = CountryState.new
    expect(new_state).to_not be_valid

    new_state.save
    expect(CountryState.count).to eq 0
  end

  it "should generate slug" do
    new_state = create(:country_state, name: 'Madhya Pradesh')
    expect(new_state.slug).to eq 'madhya-pradesh'
  end

  it "should know its current assembly election" do
    new_state = create(:country_state, name: 'Madhya Pradesh')

    election_past = Election.create!(country_state: new_state,
                                     kind: Election::KIND_ASSEMBLY,
                                     starts_at: 200.days.ago,
                                     ends_at: 100.days.ago)

    election_current = Election.create!(country_state: new_state,
                                        kind: Election::KIND_ASSEMBLY,
                                        starts_at: 200.days.ago,
                                        ends_at: 100.days.from_now)

    election_future = Election.create!(country_state: new_state,
                                       kind: Election::KIND_ASSEMBLY,
                                       starts_at: 200.days.from_now,
                                       ends_at: 300.days.from_now)

    ## changing to latest created election
    expect(new_state.current_assembly_election).to eq election_future
  end

  it "should know its current parliamentary election" do
    election_past = Election.create!(
      kind: Election::KIND_PARLIAMENT,
      starts_at: 200.days.ago,
      ends_at: 100.days.ago
    )

    election_current = Election.create!(
      kind: Election::KIND_PARLIAMENT,
      starts_at: 200.days.ago,
      ends_at: 100.days.from_now
    )

    election_future = Election.create!(
      kind: Election::KIND_PARLIAMENT,
      starts_at: 200.days.from_now,
      ends_at: 300.days.from_now
    )

    ## changing to latest created election
    expect(CountryState.current_parliamentary_election).to eq election_future
  end

  it "should be marked to launched" do
    new_state = create(:country_state)
    expect(new_state.has_launched?).to be_falsey
    new_state.mark_launched
    expect(CountryState.find(new_state.id).has_launched?).to be_truthy
    new_state.unmark_launched
    expect(CountryState.find(new_state.id).has_launched?).to be_falsey
  end
end
