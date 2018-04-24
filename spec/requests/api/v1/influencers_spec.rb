require 'rails_helper'

RSpec.describe "Influencers Spec", type: :request do
  let(:headers) do
    {
      "Accept" => "application/json",
      "CONTENT_TYPE" => "application/json",
      "HTTP_USER_AGENT" => "RSpec"
    }
  end

  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/influencers/:id" do
    it "should get influencer profile" do
      user = User.order('created_at asc').first
      get api_v1_influencer_path(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: request_headers
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
      expect(data["contact_info"]).to be_truthy
    end

    it "should not show profile percentage if not logged in" do
      user = User.order('created_at asc').first
      get api_v1_influencer_path(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: DataHelper::HEADERS
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
      expect(data["contact_info"]).to be_truthy
      expect(data["score"]).to be_truthy
      expect(data["profile_percentage_complete"]).to be_falsey
    end
  end

  describe "GET /api/v1/influencers/influencer" do
    it "should get influencer profile" do
      get api_v1_influencers_influencer_url, headers: request_headers
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
      expect(data["contact_info"]).to be_truthy
      expect(data["profile_percentage_complete"]).to be_truthy
      expect(data["score"]).to be_truthy
    end

    it "should not show profile percentage of other users" do
      user = User.order('created_at desc').first
      first_user = User.order('created_at asc').first
      get api_v1_influencer_path(id: first_user.id), params: { constituency_id: user.assembly_constituency.id }, headers: DataHelper::HEADERS.merge(user.create_new_auth_token)
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
      expect(data["contact_info"]).to be_truthy
      expect(data["profile_percentage_complete"]).to be_falsey
      expect(data["score"]).to be_truthy
    end
  end

  describe "PATCH /api/v1/influencers/:id" do
    it "should update influencer profile with the sent params" do
      user = Candidate.first.profile.user
      before_religion = user.profile.religion.name
      after_religion = Religion.all.map(&:name).reject { |name| name == before_religion }.sample
      religion_id = Religion.find_by(name: after_religion).id

      before_caste = user.profile.caste.name
      after_caste = Caste.all.map(&:name).reject { |name| name == before_caste }.sample
      caste_id = Caste.find_by(name: after_caste).id

      before_party_abbr = user.profile.candidate.candidatures.order("created_at desc").first.party.abbreviation
      after_party_abbr = Party.all.map(&:abbreviation).reject { |name| name == before_party_abbr }.sample

      new_fb = "facebook.com/editneta"
      new_twitter = "twitter.com/editneta"
      new_phone = "1000000000"
      new_pin_code = "000000"

      patch api_v1_influencer_path(id: user.id), params: { gender: "Female", religion_id: religion_id, caste_id: caste_id, contact: { facebook: new_fb, twitter: new_twitter, phone: new_phone, pincode: new_pin_code }, party_abbr: after_party_abbr }.to_json, headers: headers.merge(user.create_new_auth_token)
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["info"]["religion"]).to eq(after_religion)
      user = user.reload
      expect(user.profile.religion.name).to eq(after_religion)
      expect(data["info"]["caste"]).to eq(after_caste)
      expect(user.profile.caste.name).to eq(after_caste)
      expect(data["contact_info"]["facebook"]).to eq(new_fb)
      expect(user.profile.contact["facebook"]).to eq(new_fb)
      expect(data["contact_info"]["twitter"]).to eq(new_twitter)
      expect(user.profile.contact["twitter"]).to eq(new_twitter)
      expect(data["contact_info"]["phone"]).to eq(new_phone)
      expect(user.profile.contact["phone"]).to eq(new_phone)
      expect(data["info"]["pincode"]).to eq(new_pin_code)
      expect(user.profile.contact["pincode"]).to eq(new_pin_code)
      new_party_abbr = user.profile.candidate.candidatures.order("created_at desc").first.party.abbreviation
      expect(new_party_abbr).to eq(after_party_abbr)
      expect(new_party_abbr).not_to eql(before_party_abbr)
    end
  end

  describe "PATCH /api/v1/influencers/influencer/update" do
    it "should update influencer profile with the sent params" do
      user = User.order('created_at asc').first
      before_constituency_name = Constituency.find(user.constituency_id).name
      after_constituency_name = Constituency.all.map(&:name).reject { |name| name == before_constituency_name }.sample
      after_constituency_id = Constituency.find_by(name: after_constituency_name).id
      patch api_v1_influencers_influencer_update_url, params: { constituency_id: after_constituency_id }.to_json, headers: headers.merge(user.create_new_auth_token)
      user = user.reload
      expect(user.constituency_id).to eq(after_constituency_id)
    end
  end

  describe "GET /api/v1/influencers" do
    it "should get list of influencers will fail if constituency_id is not sent" do
      get api_v1_influencers_url, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq(422)
    end

    it "should get list of influencers for assembly constituency" do
      constituency = Constituency.find_by(name: "Bengaluru South Constituency")
      get api_v1_influencers_url, params: { constituency_id: constituency.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to eq(User.count - Candidate.count)
      data.each do |influencer|
        expect(influencer["influencer_id"]).to be_truthy
        expect(influencer["influencer_name"]).to be_truthy
        expect(influencer["score"]).to be_truthy
      end
    end
  end

  describe "GET /api/v1/influencers/search" do
    it "should not search for influencers for a constituency if query param is not passed" do
      get search_api_v1_candidatures_url, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq(422)
    end

    it "should get particular influencer profile when query param is passed" do
      constituency = Constituency.find_by(name: "Bengaluru South Constituency")
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, query: "user1" }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      data.each do |influencer|
        expect(influencer["influencer_id"]).to be_truthy
        expect(influencer["influencer_name"]).to be_truthy
        expect(influencer["influencer_name"]).to eq('user1')
        expect(influencer["score"]).to be_truthy
      end
    end

    it "should get list of all influencers for assembly constituency when generic query param is passed " do
      constituency = Constituency.find_by(name: "Bengaluru South Constituency")
      get api_v1_influencers_url, params: { constituency_id: constituency.id, query: "user" }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to eq(User.count - Candidate.count)
      data.each do |influencer|
        expect(influencer["influencer_id"]).to be_truthy
        expect(influencer["influencer_name"]).to be_truthy
        expect(influencer["score"]).to be_truthy
      end
    end

    it "should get empty list when invalid query param is passed" do
      constituency = Constituency.find_by(name: "Bengaluru South Constituency")
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, query: "user7" }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to eq(0)
    end
  end

  describe "GET /api/v1/influencers/:id/issues" do
    it "should get all the issues created of particular user in a constituency" do
      user = Post.first.user
      count = Post.where(user_id: user.id).count
      get posts_api_v1_influencer_path(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: headers.merge(user.create_new_auth_token)
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["posts"].count).to eq(count)
    end
  end

  describe "GET /api/v1/influencers/:id/activity" do
    it "should get user activity, posts, likes, comments, memberships" do
      user = User.order('created_at asc').first
      count = Activity.where(user_id: user.id).count
      get activity_api_v1_influencer_url(id: user.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(count - 1) # user registration is one activity as well
      activities = data["activities"]
      activities.each do |activity|
        expect(activity["activity_id"]).to be_truthy
        expect(activity["action"]).to be_truthy
        expect(activity["resource"]).to be_truthy
        expect(activity["score"]).to be_truthy
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
      post = Post.first
      post.comments.build(text: "by user #{user.profile.name}", user_id: user.id)
      post.save
      get activity_api_v1_influencer_url(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(activities_count(user.reload.activities))
      like = Like.new(user: user, likeable: post)
      like.save
      get activity_api_v1_influencer_url(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(activities_count(user.reload.activities))
      party = Party.first
      party_membership = PartyMembership.new(user: user, party: party, is_valid: false)
      party_membership.save
      get activity_api_v1_influencer_url(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(activities_count(user.reload.activities))

      issue = create(:issue, region: user.constituency, title: Faker::Lorem.sentence, description: Faker::Lorem.paragraph, user: user, anonymous: true)
      get activity_api_v1_influencer_url(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(activities_count(user.reload.activities))
      ids = []
      data["activities"].each do |item|
        ids << item["data"]["id"]
      end
      expect(ids.include?(issue.id)).to be_truthy

      get activity_api_v1_influencer_url(id: user.id), params: { constituency_id: user.assembly_constituency.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      data["activities"].each do |item|
        expect(item["data"]["id"]).not_to eq(issue.id)
      end
    end
  end

  def activities_count(activities)
    activities.reject { |activity| activity.activable_type == 'User' }.map do |activity|
      case activity.activable_type
      when 'PollVote'
        poll_vote_id = activity.activable_id
        post = PollVote.find(poll_vote_id).poll_option.poll
        post.id
      when 'Comment'
        comment_id = activity.activable_id
        post = Comment.find(comment_id).post
        post.id
      when 'Like'
        like_id = activity.activable_id
        like = Like.find(like_id)
        post = if like.likeable.class.name == "Comment"
                 Comment.find(like.likeable_id).post
               else
                 Post.find(like.likeable_id)
               end
        post.id
      else
        post_id = activity.activable_id
        post = Post.find(post_id)
        post.id
                end
    end.uniq.count
  end

  describe "GET /api/v1/influencers/:id/scorelog" do
    it "should should get score log of a particular user" do
      user = User.order('created_at asc').first
      count = Activity.where(user_id: user.id).count
      get scorelog_api_v1_influencer_path(id: user.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["activities"].count).to eq(count - 1) # user registration is one activity as well
    end
  end
end
