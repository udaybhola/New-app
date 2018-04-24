require 'rails_helper'

RSpec.describe "Candidatures Spec" do
  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/candidatures" do
    it "should get list of candidatures for a constituency in descending order of votes" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get api_v1_candidatures_url, params: { constituency_id: constituency.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["candidate_name"]).to be_truthy
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["votes"] }
      expect(votes_arr.sort.reverse).to eq(votes_arr)
    end

    it "should get list of candidatures for a constituency in ascending order of votes" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get api_v1_candidatures_url, params: { constituency_id: constituency.id, sort_by: "votes_asc" }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["votes"] }
      expect(votes_arr.sort).to eq(votes_arr)
    end

    it "should get list of candidatures for a constituency in ascending order of party names" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get api_v1_candidatures_url, params: { constituency_id: constituency.id, sort_by: "party" }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["party_abbreviation"] }
      expect(votes_arr.sort).to eq(votes_arr)
    end
  end

  describe "GET /api/v1/candidatures/:id/search" do
    it "should not search for candidatures for a constituency if query param is not passed" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq(422)
    end

    it "should search for candidatures for a constituency in descending order of votes when query param is passed" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, query: 'neta2' }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["candidate_name"]).to be_truthy
        expect(candidate["candidate_name"]).to eq(user.profile.name)
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["votes"] }
      expect(votes_arr.sort.reverse).to eq(votes_arr)
    end

    it "should get all candidatures for a constituency in descending order of votes when generic search query param is passed" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, query: 'neta' }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      expect(data.count).to eq(Candidate.count)
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["candidate_name"]).to be_truthy
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["votes"] }
      expect(votes_arr.sort.reverse).to eq(votes_arr)
    end

    it "should list empty when invalid candidate name query param is passed" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, query: 'neta4' }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to eq(0)
    end

    it "should get list of candidatures for a constituency in ascending order of votes" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, sort_by: "votes_asc", query: 'neta' }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["votes"] }
      expect(votes_arr.sort).to eq(votes_arr)
    end

    it "should get list of candidatures for a constituency in ascending order of party names" do
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get search_api_v1_candidatures_url, params: { constituency_id: constituency.id, sort_by: "party", query: 'neta' }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["is_voted_by_me"]).to be_falsey
      end
      votes_arr = data.map { |item| item["party_abbreviation"] }
      expect(votes_arr.sort).to eq(votes_arr)
    end
  end
  
  describe "POST /api/v1/candidature/:id/vote" do
    it "should allow a user to vote for a candidate of same constituency" do
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      candidature = Candidature.joins(:election).where(candidate_id: candidate.id, constituency_id: constituency.id).order("elections.created_at desc").first
      election = candidature.election
      election.starts_at = 21.days.from_now
      election.ends_at = 30.days.from_now
      election.save
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(0)
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to be_truthy
      expect(data["candidature"]).to be_truthy
      expect(data["candidate_vote_count"]).to be_truthy
      expect(data["candidate_vote_count"]).to eq(1)
      expect(data["supported_user_info"]).to be_truthy
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(1)
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).first.is_valid).to be_truthy
      new_candidate = Candidate.second
      candidature = Candidature.joins(:election).where(candidate_id: new_candidate.id, constituency_id: constituency.id).order("elections.created_at desc").first
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      expect(CandidateVote.where(user: user, election: candidature.election).count).to eq(2)
      expect(CandidateVote.where(candidature_id: candidature.id, user: user, is_valid: true).count).to eq(1)
    end

    it "should show as voted in list for a particular candidature if the user has voted" do
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      candidature = Candidature.joins(:election).where(candidate_id: candidate.id, constituency_id: constituency.id).order("elections.created_at desc").first
      election = candidature.election
      election.starts_at = 21.days.from_now
      election.ends_at = 30.days.from_now
      election.save
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(0)
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to be_truthy
      expect(data["candidature"]).to be_truthy
      expect(data["candidate_vote_count"]).to be_truthy
      expect(data["candidate_vote_count"]).to eq(1)
      expect(data["supported_user_info"]).to be_truthy
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(1)
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).first.is_valid).to be_truthy

      get api_v1_candidatures_url, params: { constituency_id: constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data.count).to be_truthy
      data.each do |candidate|
        expect(candidate["candidate_id"]).to be_truthy
        ## old version apis
        expect(candidate["party_abbreviation"]).to be_truthy
        ## new version apis
        expect(candidate["party"]["abbreviation"]).to be_truthy
        expect(candidate["party"]["name"]).to be_truthy
        expect(candidate["votes"]).to be_truthy
        expect(candidate["percentage"]).to be_truthy
        expect(candidate["candidate_name"]).to be_truthy
        if candidate["candidature_id"] == candidature.id
          expect(candidate["is_voted_by_me"]).to be_truthy
          expect(candidate["party_and_support_info"]).to be_truthy
        else
          expect(candidate["is_voted_by_me"]).to be_falsey
        end
      end
    end

    it "should not be able to vote if election is over" do
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = Constituency.find_by(name: "Ahmedabad South Constituency")
      user.constituency_id = constituency.id
      user.save
      election = Election.find_by(country_state: CountryState.find_by(abbreviation: 'GJ'))
      party = Party.first
      candidature = create(:candidature, candidate: candidate, election: election, constituency: constituency, party: party)
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to eq(party.title)
      expect(data["candidate_vote_count"]).to eq(candidature.reload.candidate_votes.valid.count)
    end

    it "should not allow a user to vote for candidate of different constituency" do
      candidate = Candidate.first
      election = Election.find_by(country_state: CountryState.find_by(abbreviation: 'RJ'))
      constituency = Constituency.find_by(name: "Jaipur North Constituency")
      candidature = create(:candidature, candidate: candidate, election: election, constituency: constituency)
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq(422)
    end
  end

  describe "POST /api/v1/candidature/:id/cancel_vote" do
    it "should cancel the previous vote" do
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      candidature = Candidature.joins(:election).where(candidate_id: candidate.id, constituency_id: constituency.id).order("elections.created_at desc").first
      election = candidature.election
      election.starts_at = 21.days.from_now
      election.ends_at = 30.days.from_now
      election.save
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(0)
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to be_truthy
      expect(data["candidature"]).to be_truthy
      expect(data["candidate_vote_count"]).to be_truthy
      expect(data["candidate_vote_count"]).to eq(1)
      expect(data["supported_user_info"]).to be_truthy

      post cancel_vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to be_truthy
      expect(data["candidature"]).to be_truthy
      expect(data["candidate_vote_count"]).to be_truthy
      expect(data["candidate_vote_count"]).to eq(0)
      expect(data["supported_user_info"]["id"]).to be_falsey
    end

    it "should not be able to cancel if not voted" do
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      candidature = Candidature.joins(:election).where(candidate_id: candidate.id, constituency_id: constituency.id).order("elections.created_at desc").first
      election = candidature.election
      election.starts_at = 21.days.from_now
      election.ends_at = 30.days.from_now
      election.save
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(0)
      post cancel_vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq(500)
      expect(parsed_body["status"]).to eq("internal_server_error")
      expect(parsed_body["message"]).to eq("No Vote to Cancel")
    end
  end

  describe "GET /api/v1/candidatures/current_voted_candidate" do
    it "should get current voted candidate info of election of the constituency provided if already voted" do 
      candidate = Candidate.first
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      candidature = Candidature.joins(:election).where(candidate_id: candidate.id, constituency_id: constituency.id).order("elections.created_at desc").first
      election = candidature.election
      election.starts_at = 21.days.from_now
      election.ends_at = 30.days.from_now
      election.save
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(0)
      post vote_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency.id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to be_truthy
      expect(data["candidature"]).to be_truthy
      expect(data["candidate_vote_count"]).to be_truthy
      expect(data["candidate_vote_count"]).to eq(1)
      expect(data["supported_user_info"]).to be_truthy
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).count).to eq(1)
      expect(CandidateVote.where(candidature_id: candidature.id, user: user).first.is_valid).to be_truthy

      get current_voted_candidate_api_v1_candidatures_path(constituency_id: constituency.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to be_truthy
      expect(data["candidature"]).to be_truthy
      expect(data["candidate_vote_count"]).to be_truthy
      expect(data["candidate_vote_count"]).to eq(1)
      expect(data["supported_user_info"]).to be_truthy
    end 

    it "should show empty candidate info if not voted" do 
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get current_voted_candidate_api_v1_candidatures_path(constituency_id: constituency.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["party_name"]).to eq("")
      expect(data["candidature"]).to eq("")
      expect(data["supported_user_info"].empty?).to be_truthy
    end

    it "should give 401 if headers are not provided" do 
      user = User.order('created_at asc').first
      constituency = user.assembly_constituency
      get current_voted_candidate_api_v1_candidatures_path(constituency_id: constituency.id), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["errors"][0]).to eq("You need to sign in or sign up before continuing.")
    end
  end

  describe "GET /api/v1/candidates/:id/messages" do
    it "should show  messages of a candidate for a particular candidature" do
      candidature = Candidature.first
      message1 = create(:message, candidature: candidature)
      message1.attachment = build(:attachment, media: "dfee")
      message1.save
      get messages_api_v1_candidature_path(id: candidature.id), params: { constituency_id: candidature.constituency.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(candidature.reload.messages.count).to eq(data.count)
      data.each do |message|
        expect(message["id"]).to be_truthy
        expect(message["title"]).to be_truthy
        expect(message["attachment"]).to be_truthy
        expect(message["attachment"]["media"]).to be_truthy
      end
      message2 = create(:message, candidature: candidature)
      message2.attachment = build(:attachment, media: "dfee")
      message2.save
      get messages_api_v1_candidature_path(id: candidature.id), params: { constituency_id: candidature.constituency.id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(candidature.reload.messages.count).to eq(data.count)
    end
  end

  # describe "POST /api/v1/candidates/:id/message" do
  #   it "should be able to create message" do
  #     candidature = Candidature.first
  #     post message_api_v1_candidature_path(id: candidature.id), params: { constituency_id: candidature.constituency.id, title: "Hi all!", media: "http://res.cloudinary.com/starlove-dev/image/upload/v1485329001/ikddsze0rspyl1smalqh.png" }.to_json, headers: request_headers
  #     parsed_body = JSON.parse(response.body)
  #     data = parsed_body["data"]
  #     expect(data["id"]).to be_truthy
  #     expect(data["title"]).to be_truthy
  #     expect(data["attachment"]).to be_truthy
  #     expect(data["attachment"]["media"]).to be_truthy
  #   end
  # end

  describe "GET /api/v1/candidature/:id/commented_issues" do
    it "should get the issues commented by candidature" do
      candidature = Candidature.first
      user = User.order('created_at asc').first
      constituency_id = user.assembly_constituency.id
      get commented_issues_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["posts"].count).to eq(0)
      post = Post.first
      post.comments.build(text: "by leader", user_id: candidature.candidate.profile.user.id)
      post.save
      get commented_issues_api_v1_candidature_path(id: candidature.id), params: { constituency_id: constituency_id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["posts"].count).to eq(1)
    end
  end

  # describe "GET /api/v1/candidates/:id/manifesto" do
  #   it "should get latest manifesto for a particular candidate" do
  #     candidate = Candidate.first
  #     user = User.order('created_at asc').first
  #     constituency = user.assembly_constituency
  #     candidature = Candidature.where(candidate: candidate, constituency: constituency).order("created_at desc").first
  #     candidature.manifesto = File.open("#{Rails.root}/spec/images/manifesto.pdf")
  #     candidature.save
  #     get manifesto_api_v1_candidate_path(id: candidate.id), params: {constituency_id: constituency.id}, headers: request_headers
  #     parsed_body = JSON.parse(response.body)
  #     byebug
  #   end
  # end
end
