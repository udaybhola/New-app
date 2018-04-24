require 'rails_helper'

RSpec.describe "Parties Spec" do
  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/parties" do
    it "should get all parties" do
      parties_count = Party.all.count
      get api_v1_parties_url, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to eq(parties_count)
      data.each do |party|
        expect(party["id"]).to be_truthy
        expect(party["party_name"]).to be_truthy
        expect(party["party_image"]).to be_nil
      end
    end
  end

  describe "GET /api/v1/parties/:id" do
    it "should get particular party info" do
      party = Party.first
      sample_url = "twitter.com/partyxyz"
      party.contact[:twitter] = sample_url
      party.save!
      get api_v1_party_path(id: party.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["id"]).to eq(party.id)
      expect(data["party_name"]).to eq(party.title)
      expect(data["party_abbreviation"]).to eq(party.abbreviation)
      expect(data["contact_info"]).to be_truthy
      expect(data["contact_info"]["twitter"]).to be_truthy
      expect(data["contact_info"]["twitter"]).to eq(sample_url)
    end
  end

  describe "POST /api/v1/parties/:id/join" do
    it "should create a new request for joining the party" do
      party = Party.first
      expect(PartyMembership.count).to eq(0)
      user = User.order('created_at asc').first
      post join_api_v1_party_path(id: party.id), params: { description: Faker::Lorem.sentences, constituency_id: user.assembly_constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status"]).to eq(200)
      expect(parsed_body["message"]).to eq("submitted requested for joining")
      user = User.order('created_at asc').first
      party_membership = PartyMembership.first
      expect(party_membership.is_valid).to be_falsey
      expect(party_membership.user_id).to eq(user.id)
      party_membership = PartyMembership.first
      party_membership.is_valid = true
      party_membership.save!
      post join_api_v1_party_path(id: party.id), params: { description: Faker::Lorem.sentences, constituency_id: user.assembly_constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status"]).to eq(200)
      expect(parsed_body["message"]).to eq("already joined")
    end
  end

  describe "GET /api/v1/parties/:id/party_leaders" do
    it "should get all the leaders of the party" do
      party = Party.first
      get party_leaders_api_v1_party_path(id: party.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to eq(PartyLeader.where(party: party).count)
      data.each do |party_leader|
        expect(party_leader["position"]).to be_truthy
        expect(party_leader["position_hierarchy"]).to be_truthy
        expect(party_leader["candidate_info"]).to be_truthy
      end
    end
  end
end
