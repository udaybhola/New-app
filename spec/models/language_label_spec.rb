require 'rails_helper'

RSpec.describe LanguageLabel, type: :model do
  it "should create from csv row" do
    translations = {
    }
    translations["Key"] = "your-contituency"
    translations["English"] = "Your Constituency"
    translations["Hindi"] = "आपकी विधानसभा"
    translations["Punjabi"] = "ਤੁਹਾਡੇ ਚੋਣ ਖੇਤਰ"
    translations["Bengali"] = "আপনার মতামত"
    translations["Telugu"] = "మీ నియోజకవర్గం"
    translations["Kannada"] = ""
    translations["Marathi"] = ""

    label = LanguageLabel.create_from_csv_row(translations)
    label_one = LanguageLabel.create_from_csv_row(translations)
    label_two = LanguageLabel.create_from_csv_row(translations)
    expect(label).to eq(label_one)
    expect(label_two).to eq(label_one)
  end
end
