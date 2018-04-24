require 'rails_helper'

RSpec.describe Education, type: :model do
  it { should validate_presence_of :name }

  it "should save with valid attributes" do
    new_education = build(:education)
    expect(new_education).to be_valid

    new_education.save
    expect(Education.count).to eq 1
  end
end
