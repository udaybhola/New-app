require 'rails_helper'

RSpec.describe "Candidates spec", type: :request do
  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/candidates/:id" do
    it "should get candidate profile" do
      candidate = Candidate.order('created_at asc').first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get api_v1_candidate_path(id: candidate.id), params: { constituency_id: constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["info"]).to be_truthy
      expect(data["info"]["name"]).to be_truthy
      expect(data["info"]["religion"]).to be_truthy
      expect(data["info"]["caste"]).to be_truthy
      expect(data["info"]["profession"]).to be_truthy
      expect(data["info"]["state"]).to be_truthy
      expect(data["info"]["constituency"]).to be_truthy
      expect(data["info"]["pincode"]).to be_truthy
      expect(data["info"]["income"]).to be_truthy
      expect(data["info"]["assets"]).to be_truthy
      expect(data["info"]["liabilities"]).to be_truthy
      expect(data["info"]["criminal_cases"]).to be_truthy
      expect(data["contact_info"]).to be_truthy
      expect(data["contact_info"]["website"]).to be_truthy
      expect(data["contact_info"]["twitter"]).to be_truthy
      expect(data["contact_info"]["facebook"]).to be_truthy
      expect(data["party_and_support_info"]).to be_truthy
      expect(data["party_and_support_info"]["party_name"]).to be_truthy
      expect(data["party_and_support_info"]["candidature"]).to be_truthy
      expect(data["party_and_support_info"]["candidate_vote_count"]).to be_truthy
      expect(data["party_and_support_info"]["supported_user_info"]).to be_truthy
      expect(candidate.profile.name).to eq(data["info"]["name"])
      expect(candidate.profile.religion.name).to eq(data["info"]["religion"])
      expect(candidate.profile.caste.name).to eq(data["info"]["caste"])
      expect(candidate.candidatures.where(constituency_id: constituency.id).order("created_at desc").first.party.title).to eq(data["party_and_support_info"]["party_name"])
    end
  end

  describe "GET /api/v1/candidates/:id/candidatures" do
    it "should get list of candidatures for a particular candidate" do
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get candidatures_api_v1_candidate_path(id: candidate.id), params: { constituency_id: constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidature|
        expect(candidature["id"]).to be_truthy
        expect(candidature["year"]).to be_truthy
        expect(candidature["constituency"]).to be_truthy
        expect(candidature["election"]).to be_truthy
        expect(candidature["party"]).to be_truthy
      end
    end
  end

  describe "GET /api/v1/candidates/:candidate_id/posts" do
    it "should get all posts of candidate including commented and liked" do
      user = User.find_by(email: "neta3@neta.com")
      post = create(:issue, region: user.assembly_constituency, title: Faker::Lorem.sentence, description: Faker::Lorem.paragraph, user: user)
      post.comments.build(text: "by user #{user.profile.name}", user_id: user.id)
      post.save
      like = Like.new(user: user, likeable: post)
      like.save
      count = user.posts.count
      ## all where for only one post
      # + user.comments.count + user.likes.count + user.valid_poll_votes.count
      get posts_api_v1_candidate_path(user.profile.candidate.id), params: { constituency_id: user.constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(count)
      activities = data["activities"]
      activities.each do |activity|
        expect(activity["activity_id"]).to be_truthy
        expect(activity["action"]).to be_truthy
        expect(activity["resource"]).to be_truthy
        post = activity["data"]
        expect(post["type"]).to be_truthy
        if post["type"] == "poll"
          expect(post["question"]).to be_truthy
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        # expect(post["created_by"]).to be_truthy
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
      end
    end

    it "should get no posts if candidate is not linked to user yet" do
      candidature = create(:candidature)
      candidate = candidature.candidate
      get posts_api_v1_candidate_path(candidate.id), params: { constituency_id: candidature.constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      activities = data["activities"]
      expect(activities.count).to eq(0)
    end
  end
end
