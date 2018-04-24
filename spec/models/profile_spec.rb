require 'rails_helper'

RSpec.describe Profile, type: :model do
  it "should save with valid attributes" do
    new_profile = build(:profile)
    expect(new_profile).to be_valid

    new_profile.save
    expect(Profile.count).to eq 1
  end

  it "should save contact details" do
    new_profile = create(:profile, phone: '4949494949', email: 'foobar@gmail.com')

    expect(new_profile.phone).to eq '4949494949'
    expect(new_profile.email).to eq 'foobar@gmail.com'
  end

  it "should save financial details" do
    new_profile = create(:profile, income: 48492, assets: 47399839398765)
    expect(new_profile.income).to eq 48492
    expect(new_profile.assets).to eq 47399839398765
  end

  it "should generate a slug if name is present" do
    new_profile = create(:profile, name: "Manpreet Singh Badal")
    expect(new_profile.slug).to eq "manpreet-singh-badal"
  end

  it "should save return religion" do
    religion = create(:religion, name: 'Sikh')
    new_profile = create(:profile, religion: religion)
    expect(new_profile.religion.name).to eq 'Sikh'
  end

  it "should save return caste" do
    caste = create(:caste, name: 'Jatt')
    new_profile = create(:profile, caste: caste)
    expect(new_profile.caste.name).to eq 'Jatt'
  end

  it "should save return education" do
    new_profile = create(:profile, education: 'Graduate from Gandhi Universisty')
    expect(new_profile.education).to eq 'Graduate from Gandhi Universisty'
  end

  it "should save return profession" do
    profession = create(:profession, name: 'Private')
    new_profile = create(:profile, profession: profession)
    expect(new_profile.profession.name).to eq 'Private'
  end
end
