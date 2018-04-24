require 'rails_helper'

RSpec.describe "Constituencies spec", type: :request do
  before(:each) do
    data_helper_create_data_set
  end

  describe "POST /api/v1/constituencies/latlng" do
    it "should return error when lat and lng are not valid" do
      get latlng_api_v1_constituencies_url, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["message"]).to eq "Must have a valid latitude and longitude"
    end
    it "should return success response for valid lat lng" do
      get latlng_api_v1_constituencies_url, headers: request_headers, params: { lat: 31.322393, lng: 75.5383142 }
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["message"]).to eq "Could not find a assemble constituency with given lat and lng"
    end
  end
end
