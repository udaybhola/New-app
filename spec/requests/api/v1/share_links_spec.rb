require 'rails_helper'

RSpec.describe "ShareLinks spec", type: :request do
  before(:each) do
    data_helper_create_data_set
  end

  describe "POST /api/v1/share_links/post" do
    it "Should error out without post id" do
      post post_api_v1_share_links_url, params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["message"]).to eq("id param cannot be empty")
    end

    it "Should error out without candidature id" do
      post candidature_api_v1_share_links_url, params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["message"]).to eq("id param cannot be empty")
    end

    it "Should error out without influencer id" do
      post influencer_api_v1_share_links_url, params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["message"]).to eq("id param cannot be empty")
    end

    it "Should provide proper json for poll" do
      poll = Poll.first
      post post_api_v1_share_links_url, params: { id: poll.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]["title"]).not_to be_empty
    end

    it "Should provide proper json for issue" do
      issue = Issue.first
      post post_api_v1_share_links_url, params: { id: issue.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]["title"]).not_to be_empty
    end

    it "Should provide proper json for candidature" do
      candidature = Candidature.first
      post candidature_api_v1_share_links_url, params: { id: candidature.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]["description"]).not_to be_empty
    end

    it "Should provide proper json for influencer" do
      user = User.first
      post influencer_api_v1_share_links_url, params: { id: user.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]["description"]).not_to be_empty
    end
  end
end
