require 'rails_helper'

def translations
  translations_content = {
  }
  translations_content["Key"] = "your-contituency"
  translations_content["English"] = "Your Constituency"
  translations_content["Hindi"] = "आपकी विधानसभा"
  translations_content["Punjabi"] = "ਤੁਹਾਡੇ ਚੋਣ ਖੇਤਰ"
  translations_content["Bengali"] = "আপনার মতামত"
  translations_content["Telugu"] = "మీ నియోజకవర్గం"
  translations_content["Kannada"] = ""
  translations_content["Marathi"] = ""
  translations_content
end

RSpec.describe "Translations spec", type: :request do
  before(:each) do
    data_helper_create_data_set
    Language.seed
    LanguageLabel.create_from_csv_row(translations)
  end

  describe "GET /api/v1/translations/available_languages" do
    it "Should get all available languages" do
      first = Language.first
      first.availability = true
      first.save!
      get available_languages_api_v1_translations_url, params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]).not_to be_empty
      expect(parsed_body["data"][0]["id"]).to eq(first.id)
      expect(parsed_body["data"][0]["name"]).to eq(first.name)
    end
  end

  describe "GET /api/v1/translations?language=?" do
    it "Should get all available translations for given language" do
      get api_v1_translations_url, params: { language: 'Hindi' }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]).not_to be_empty
      expect(parsed_body["data"][0]["key"]).to eq(translations["Key"])
      expect(parsed_body["data"][0]["value"]).to eq(translations["Hindi"])
    end
  end
end
