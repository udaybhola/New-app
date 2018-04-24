require 'rails_helper'

RSpec.describe "Posts Categories Count spec", type: :request do
  let(:constituency_id) { Constituency.where("parent_id is not null").first.id }

  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/posts/categories" do
    it "Should list posts categories along with counts" do
      get api_v1_posts_categories_url, params: { constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      data.each do |issue|
        expect(issue["count"]).to be_truthy
        expect(issue["name"]).to be_truthy
        expect(issue["id"]).to be_truthy
        expect(issue["image"]).to be_truthy
        expect(issue["slug"]).to be_truthy
      end
    end

    it "Should list posts categories along with counts with categories name in ascending order" do
      get api_v1_posts_categories_url, params: { constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      data.each_with_index do |issue, _index|
        expect(issue["count"]).to be_truthy
        expect(issue["name"]).to be_truthy
        expect(issue["id"]).to be_truthy
        expect(issue["image"]).to be_truthy
        expect(issue["slug"]).to be_truthy
      end
      name_arr = data.map { |item| item["name"] }
      expect(name_arr.sort).to eq(name_arr)
    end
  end
end
