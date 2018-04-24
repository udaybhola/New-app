require 'rails_helper'

RSpec.describe "Categories spec", type: :request do
  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/categories" do
    it "should get list of categories" do
      get api_v1_categories_url, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data).to be_truthy
      expect(data.count).to eq(Category.count)
      expect(Category.all.map(&:name).include?(data[0]["name"])).to be_truthy
    end
  end
end
