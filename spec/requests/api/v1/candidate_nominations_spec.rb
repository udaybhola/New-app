require 'rails_helper'

RSpec.describe "CandidateNominations spec", type: :request do
  before(:each) do
    data_helper_create_data_set
  end

  describe "POST /api/v1/candidate_nominations/create" do
    it "Should give 500" do
      post api_v1_candidate_nominations_url, params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status"]).to eq(500)
    end

    it "Should give validation error" do
      post api_v1_candidate_nominations_url, params: { candidate_nomination: {} }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status"]).to eq(500)
    end

    it "Should create nomination without news and pr links" do
      post api_v1_candidate_nominations_url,
           params: { candidate_nomination: {
             name: 'Hello',
             age: 28,
             election_kind: 'assembly',
             party_id: Party.first.id,
             country_state_id: CountryState.first.id,
             assembly_id: Constituency.assembly.first.id,
             parliament_id: Constituency.parliamentary.first.id
           } }.to_json,
           headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status_code"]).to eq(1)
    end

    it "Should create nomination with news and pr links" do
      post api_v1_candidate_nominations_url,
           params: { candidate_nomination: {
             name: 'Hello',
             age: 28,
             election_kind: 'assembly',
             party_id: Party.first.id,
             country_state_id: CountryState.first.id,
             assembly_id: Constituency.assembly.first.id,
             parliament_id: Constituency.parliamentary.first.id,
             news_pr_links: ["http://google.com", "http://apple.com"]
           } }.to_json,
           headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status_code"]).to eq(1)
      expect(CandidateNomination.first.news_pr_links).to include("http://apple.com")
    end
  end
end
