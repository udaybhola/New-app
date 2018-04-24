require 'rails_helper'

RSpec.describe User, type: :model do
  it "should belong to MLA constituency & MP constituency" do
    state = create(:country_state, name: 'Telangana')
    parliamentary_constituency = create(:constituency, country_state: state, name: 'Hyderabad')
    assembly_constituency = create(:constituency, country_state: state, name: 'Secunderabad', parent: parliamentary_constituency)

    user = create(:user, assembly_constituency: assembly_constituency)

    expect(user.assembly_constituency).to eq assembly_constituency
    expect(user.parliamentary_constituency).to eq parliamentary_constituency
    expect(user.country_state).to eq state
  end

  it "should not throw an error if constituency is not set" do
    user = create(:user)

    expect(user.assembly_constituency).to eq nil
    expect(user.parliamentary_constituency).to eq nil
    expect(user.country_state).to eq nil
  end

  it "should bootstrap user activity with 0 score" do
    user = create(:user)
    expect(user.activities.count).to eq 1
    expect(user.activities.first.score).to eq 0
  end
end
