require 'rails_helper'

RSpec.describe Caste, type: :model do
  it { should validate_presence_of :name }

  it "should save with valid attributes" do
    new_caste = build(:caste)
    expect(new_caste).to be_valid

    new_caste.save
    expect(Caste.count).to eq 1
  end
end
