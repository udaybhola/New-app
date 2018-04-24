require 'rails_helper'

RSpec.describe Language, type: :model do
  it "should create only unique name" do
    eng = Language.find_or_create_by(name: 'english')
    expect(eng.id).not_to be_blank
    expect(eng.availability).to be_falsey
  end

  it "Multiple seeds should not create new entries" do
    Language.seed
    items = Language.all.map { |item| item }

    Language.seed
    items_one = Language.all.map { |item| item }

    Language.seed
    items_two = Language.all.map { |item| item }

    expect(items).to eq(items_one)
    expect(items_two).to eq(items_one)
  end

  it "should seed all languages" do
    Language.seed
    Language.all.each do |lang|
      expect(Language::ALL).to include(lang.name)
    end
  end
end
