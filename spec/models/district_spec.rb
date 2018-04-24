require 'rails_helper'

RSpec.describe District, type: :model do
  it "should save with valid attributes" do
    new_district = build(:district)
    expect(new_district).to be_valid

    new_district.save
    expect(District.count).to eq 1
  end

  it "is not valid without a name" do
    new_district = build(:district, name: nil)
    expect(new_district).to_not be_valid

    new_district.save
    expect(District.count).to eq 0
  end

  it "should belong to a state" do
    new_district = create(:district)
    expect(new_district.country_state).to eq CountryState.first
  end

  it "can have many constituencies"
end
