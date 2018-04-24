require 'rails_helper'

RSpec.describe CandidateNomination, type: :model do
  before(:each) do
    new_state = create(:country_state, name: 'Telangana')
    party = create(:party)
    parliamentary_constituency = create(:constituency, name: 'Hyderabad', country_state: new_state)
    create(:constituency, name: 'Secunderabad', parent: parliamentary_constituency, country_state: new_state)
  end

  it "should not be valid with out party" do
    cn = build(:candidate_nomination)
    expect(cn).not_to be_valid
    expect(cn.errors[:party]).not_to be_empty

    cn.party = Party.first
    expect(cn).not_to be_valid
    expect(cn.errors[:party]).to be_empty
  end

  it "should not be without name" do
    cn = build(:candidate_nomination)
    cn.name = ""
    expect(cn).not_to be_valid
    expect(cn.errors[:name]).not_to be_empty

    cn.name = "Hello"
    expect(cn).not_to be_valid
    expect(cn.errors[:name]).to be_empty
  end

  it "should not be valid without age" do
    cn = build(:candidate_nomination)
    cn.age = ""
    expect(cn).not_to be_valid
    expect(cn.errors[:age]).not_to be_empty

    cn.age = "Hello"
    expect(cn).not_to be_valid
    expect(cn.errors[:age]).not_to be_empty

    cn.age = "28"
    expect(cn).not_to be_valid
    expect(cn.errors[:age]).to be_empty
  end

  it "should not be valid without state" do
    cn = build(:candidate_nomination)
    expect(cn).not_to be_valid
    expect(cn.errors[:country_state]).not_to be_empty

    cn.country_state = CountryState.first
    expect(cn).not_to be_valid
    expect(cn.errors[:country_state]).to be_empty
  end

  it "should not be valid without parliament" do
    cn = build(:candidate_nomination)
    expect(cn).not_to be_valid
    expect(cn.errors[:parliament]).not_to be_empty
    cn.parliament = Constituency.parliamentary.first
    expect(cn).not_to be_valid
    expect(cn.errors[:parliament]).to be_empty
  end

  it "should not be valid without assembly" do
    cn = build(:candidate_nomination)
    expect(cn).not_to be_valid
    expect(cn.errors[:assembly]).not_to be_empty
    cn.assembly = Constituency.assembly.first
    expect(cn).not_to be_valid
    expect(cn.errors[:assembly]).to be_empty
  end

  it "should not be valid without election kind" do
    cn = build(:candidate_nomination)
    expect(cn).not_to be_valid
    expect(cn.errors[:election_kind]).not_to be_empty

    cn = build(:candidate_nomination)
    cn.election_kind = "hey"
    expect(cn).not_to be_valid
    expect(cn.errors[:election_kind]).not_to be_empty

    cn = build(:candidate_nomination)
    cn.election_kind = "assembly"
    expect(cn).not_to be_valid
    expect(cn.errors[:election_kind]).to be_empty

    cn = build(:candidate_nomination)
    cn.election_kind = "parliament"
    expect(cn).not_to be_valid
    expect(cn.errors[:election_kind]).to be_empty
  end

  it "should be valid with empty news and pr links" do
    cn = create(:candidate_nomination,
                name: 'Helloo',
                age: '28',
                election_kind: 'assembly',
                party: Party.first,
                country_state: CountryState.first,
                assembly: Constituency.assembly.first,
                parliament: Constituency.parliamentary.first)
    expect(cn).to be_valid
    expect(cn.news_pr_links).to be_blank
  end

  it "should have news and pr links if present" do
    cn = create(:candidate_nomination,
                name: 'Helloo',
                age: '28',
                election_kind: 'assembly',
                party: Party.first,
                country_state: CountryState.first,
                assembly: Constituency.assembly.first,
                parliament: Constituency.parliamentary.first)
    expect(cn).to be_valid
    expect(cn.news_pr_links).to be_blank
    cn.meta = {
      news_pr_links: ["http://google.com", "http://apple.com"]
    }
    expect(cn).to be_valid
    expect(cn.news_pr_links).to include("http://google.com")
    expect(cn.news_pr_links).to include("http://apple.com")
  end
end
