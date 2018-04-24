require 'rails_helper'

RSpec.describe "Posts spec", type: :request do
  let(:constituency_id) { Constituency.where("parent_id is not null").first.id }

  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/posts" do
    it "Should list trending posts of pc of provided ac" do
      bengaluru_south = Constituency.find_by(name: "Bengaluru South Constituency")
      get api_v1_posts_url, params: { sort_by: "score", constituency_id: bengaluru_south.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      post_one_score_count = 0
      post_two_score_count = 0
      posts.each_with_index do |post, index|
        expect(post["type"]).to be_truthy
        if post["type"] == "Poll"
          expect(post["question"]).to be_truthy
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        # expect(post["created_by"]).to be_truthy
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
        if index == 0
          id = post["id"]
          post_one_score_count = Post.find(id).score
        elsif index == 1
          id = post["id"]
          post_two_score_count = Post.find(id).score
        end
      end
      # TODO fix comments_count not getting updated
      expect(post_one_score_count >= post_two_score_count).to be_truthy
      expect(posts.count).to eq(Post.state(bengaluru_south.country_state.id).where.not(user_id: nil).count)
    end

    it "Should list all posts of pc of provided ac" do
      bengaluru_south = Constituency.find_by(name: "Bengaluru South Constituency")
      get api_v1_posts_url, params: { sort_by: "newest", constituency_id: bengaluru_south.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      posts.each_with_index do |post, _index|
        expect(post["type"]).to be_truthy
        if post["type"] == "Poll"
          expect(post["question"]).to be_truthy
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
      end
      expect(posts.count).to eq(Post.state(bengaluru_south.country_state.id).where.not(user_id: nil).count)
      create(:issue, region: Constituency.find_by(name: "Bengaluru Central Constituency"), title: "Test", description: "Test", user: User.order('created_at asc').first)
      get api_v1_posts_url, params: { sort_by: "newest", constituency_id: bengaluru_south.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      posts = data["posts"]
      expect(posts.count).to eq(Post.state(bengaluru_south.country_state.id).where.not(user_id: nil).count)
      get api_v1_posts_url, params: { sort_by: "score", constituency_id: bengaluru_south.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      posts = data["posts"]
      expect(posts.count).to eq(Post.state(bengaluru_south.country_state.id).where.not(user_id: nil).count)
    end

    it "Should show poll options without any percentage and selected if user is not logged in" do
      get api_v1_posts_url, params: { sort_by: "score", constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      post_one_score_count = 0
      post_two_score_count = 0
      posts.each_with_index do |post, index|
        expect(post["type"]).to be_truthy
        if post["type"] == "Poll"
          expect(post["question"]).to be_truthy
          post["poll_options"].each do |poll_option|
            expect(poll_option["poll_votes_count"]).to be_falsey
            expect(poll_option["is_selected"]).to be_falsey
          end
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
        if index == 0
          id = post["id"]
          post_one_score_count = Post.find(id).score
        elsif index == 1
          id = post["id"]
          post_two_score_count = Post.find(id).score
        end
      end
    end

    it "Should show poll options without any percentage if user has not voted for the poll yet " do
      get api_v1_posts_url, params: { sort_by: "score", constituency_id: constituency_id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      post_one_score_count = 0
      post_two_score_count = 0
      posts.each_with_index do |post, index|
        expect(post["type"]).to be_truthy
        if post["type"] == "Poll"
          expect(post["question"]).to be_truthy
          post["poll_options"].each do |poll_option|
            expect(poll_option["poll_votes_count"]).to be_falsey
            expect(poll_option["is_selected"]).to be_falsey
          end
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
        if index == 0
          id = post["id"]
          post_one_score_count = Post.find(id).score
        elsif index == 1
          id = post["id"]
          post_two_score_count = Post.find(id).score
        end
      end
    end

    it "Should list posts ordered by likes when sent sort param as likes" do
      get api_v1_posts_url, params: { sort_by: "likes", constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      post_one_like_count = 0
      post_two_like_count = 0
      posts.each_with_index do |post, index|
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
        if index == 0
          post_one_like_count = post["counts"]["likes_count"]
        elsif index == 1
          post_two_like_count = post["counts"]["likes_count"]
        end
      end
      expect(post_one_like_count >= post_two_like_count).to be_truthy
    end

    it "Should list posts by descending when sort param is sent with value desc" do
      get api_v1_posts_url, params: { sort_by: "score", constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      posts.each do |post|
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

    it "Should list posts of a particular category when sent filter param of that category slug" do
      get api_v1_posts_url, params: { sort_by: "score", filter_by: "environmental-issues", constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      posts.each do |post|
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
        expect(post["category"]["name"]).to eq("Environmental Issues")
      end
    end

    it "Should list empty results for a particular category which is newly created when sent filter param as category slug" do
      Post.where(category: Category.find_by(name: "National Issues")).destroy_all
      create(:category, name: "National Issues", slug: "national-issues")
      get api_v1_posts_url, params: { sort_by: "score", filter_by: "national-issues", constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_polls"]).to eq(0)
      expect(data["no_of_issues"]).to be_truthy
      expect(data["no_of_issues"]).to eq(0)
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      expect(posts.length).to eq(0)
    end

    it "Should list posts with pagination" do
      get api_v1_posts_url, params: { sort_by: "score", filter_by: "environmental-issues", offset: 0, limit: 2, constituency_id: constituency_id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["offset"]).to eq(0.to_s)
      expect(data["limit"]).to be_truthy
      expect(data["limit"]).to eq(2.to_s)
      posts = data["posts"]
      # environmental_issues_posts_count = Post.where(category: Category.find_by(name: "Environmental Issues"), region_id: [constituency_id, Constituency.find(constituency_id).parent.id]).count
      # since random no of posts are created per category
      # TODO add this back ..
      # count = environmental_issues_posts_count >= 2 ? 2 : environmental_issues_posts_count
      # expect(posts.length).to eq(count)
      posts.each do |post|
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
        expect(post["category"]["name"]).to eq("Environmental Issues")
      end
    end
  end

  describe "GET /api/v1/posts/:id" do
    it "Should get individual post queried for poll" do
      get api_v1_post_path(id: Poll.first.id), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Poll")
      expect(data["question"]).to be_truthy
      expect(data["id"]).to be_truthy
      expect(data["poll_options"].length).to eq(Poll.first.poll_options.count)
    end

    it "Should show poll options in order uploaded" do
      constituency_id = Constituency.last.id
      category_id = Category.last.id
      poll_count = Poll.count
      post api_v1_posts_url, params: { type: "poll", question: "What do you think contributed to win of bjp?", constituencyId: constituency_id, category: category_id, answers: ["Patidars shifting Allegience", "Modis campaign", "Congress leaders unnecessary comments"] }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Poll")
      expect(data["question"]).to eq("What do you think contributed to win of bjp?")
      expect(data["poll_options"]).to be_truthy
      expect(data["anonymous"]).to be_falsey
      poll = Poll.find_by(question: "What do you think contributed to win of bjp?")
      expect(poll).to be_truthy
      expect(Poll.count).to eq(poll_count + 1)

      get api_v1_post_path(id: poll.id), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Poll")
      expect(data["question"]).to be_truthy
      expect(data["id"]).to be_truthy
      expect(data["poll_options"].length).to eq(poll.poll_options.count)
      data["poll_options"].each_with_index do |poll_option, index|
        expect(poll_option["position"]).to be_truthy
        expect(index).to eq(poll_option["position"])
        if index == 0
          expect(poll_option["answer"]).to eq("Patidars shifting Allegience")
        elsif index == 1
          expect(poll_option["answer"]).to eq("Modis campaign")
        else
          expect(poll_option["answer"]).to eq("Congress leaders unnecessary comments")
        end
      end
    end

    it "Should get individual post for issue" do
      get api_v1_post_path(id: Issue.first.id), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Issue")
      expect(data["title"]).to be_truthy
      expect(data["description"]).to be_truthy
      expect(data["id"]).to be_truthy
      expect(data["poll_options"].length).to eq(0)
    end
  end

  describe "POST /api/v1/posts/create" do
    it "Should give invalid params error message in response when all params are not present" do
      post api_v1_posts_url, params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq(422)
      expect(parsed_body["status"]).to eq("unprocessable_entity")
      expect(parsed_body["message"]).to eq("Insufficient params")
    end

    it "Should give invalid params error message in response when in response only when some params are present" do
      post api_v1_posts_url, params: { type: "poll", question: "What do you think contributed to win of bjp?" }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("record_not_found")
      expect(parsed_body["status"]).to eq(404)
      expect(parsed_body["message"]).to eq("Couldn't find Constituency without an ID")
    end

    it "Should create an issue when supplied proper params" do
      constituency_id = Constituency.last.id
      category_id = Category.last.id
      issue_count = Issue.count
      post api_v1_posts_url, params: { type: "issue", title: "Durga Matha Mandir Issue", description: "Look around you, this can be a good desc?", constituencyId: constituency_id, category: category_id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Issue")
      expect(data["title"]).to eq("Durga Matha Mandir Issue")
      expect(data["description"]).to eq("Look around you, this can be a good desc?")
      expect(data["anonymous"]).to be_falsey
      issue = Issue.find_by(description: "Look around you, this can be a good desc?")
      expect(issue).to be_truthy
      expect(Issue.count).to eq(issue_count + 1)
    end

    it "Should create a poll when supplied proper params" do
      constituency_id = Constituency.last.id
      category_id = Category.last.id
      poll_count = Poll.count
      post api_v1_posts_url, params: { type: "poll", question: "What do you think contributed to win of bjp?", constituencyId: constituency_id, category: category_id, answers: ["Patidars shifting Allegience", "Modis campaign", "Congress leaders unnecessary comments"] }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Poll")
      expect(data["question"]).to eq("What do you think contributed to win of bjp?")
      expect(data["poll_options"]).to be_truthy
      expect(data["anonymous"]).to be_falsey
      poll = Poll.find_by(question: "What do you think contributed to win of bjp?")
      expect(poll).to be_truthy
      expect(Poll.count).to eq(poll_count + 1)
    end

    it "Should create a issue with anonymous flag and also show the data as created by Anonymous when issue(s) are fetched" do
      constituency_id = Constituency.last.id
      category_id = Category.last.id
      post api_v1_posts_url, params: { type: "issue", title: "Durga Matha Mandir Issue", description: "Look around you, this can be a good desc?", constituencyId: constituency_id, category: category_id, anonymous: true }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["type"]).to eq("Issue")
      expect(data["title"]).to eq("Durga Matha Mandir Issue")
      expect(data["description"]).to eq("Look around you, this can be a good desc?")
      expect(data["created_by"]["name"]).to eq("Anonymous")

      post_id = data["id"]
      get api_v1_posts_url, params: { sort_by: "score", constituency_id: constituency_id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      post_one_score_count = 0
      post_two_score_count = 0
      posts.each_with_index do |post, index|
        expect(post["type"]).to be_truthy
        if post["id"] == post_id
          expect(post["created_by"]).to be_truthy
          expect(post["created_by"]["name"]).to eq("Anonymous")
        end
        if post["type"] == "Poll"
          expect(post["question"]).to be_truthy
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
        if index == 0
          id = post["id"]
          post_one_score_count = Post.find(id).score
        elsif index == 1
          id = post["id"]
          post_two_score_count = Post.find(id).score
        end
      end
    end
  end

  describe "POST api/v1/posts/:id/vote " do
    it "should be able to vote first time" do
      poll = Post.where(type: 'Poll').first
      answer_id = poll.poll_options.first.id
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: answer_id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["id"]).to eq(poll.id)
      expect(data["poll_options"].find { |item| item["id"] == poll.poll_options.first.id }["is_selected"]).to be_truthy
      expect(poll.poll_options.first.poll_votes.count).to eq(1)
      expect(poll.poll_options.first.poll_votes.first.is_valid).to be_truthy
    end

    it "should show poll options for a poll with percentages once the user votes" do
      user = User.order('created_at asc').first
      poll = create(:poll)
      new_user = create(:user)
      profile = create(:profile)
      new_user.profile = profile
      new_user.save
      poll.user = new_user
      poll.region_id = user.constituency_id
      poll.save
      answer_id = poll.poll_options.first.id
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: answer_id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["id"]).to eq(poll.id)
      expect(data["poll_options"].find { |item| item["id"] == poll.poll_options.first.id }["is_selected"]).to be_truthy
      expect(poll.poll_options.first.poll_votes.count).to eq(1)
      expect(poll.poll_options.first.poll_votes.first.is_valid).to be_truthy

      get api_v1_posts_url, params: { sort_by: "score", constituency_id: constituency_id }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["no_of_polls"]).to be_truthy
      expect(data["no_of_issues"]).to be_truthy
      expect(data["offset"]).to be_truthy
      expect(data["limit"]).to be_truthy
      posts = data["posts"]
      posts.each_with_index do |post, _index|
        expect(post["type"]).to be_truthy
        if post["type"] == "Poll"
          expect(post["question"]).to be_truthy
          if post["id"] == poll.id
            post["poll_options"].each do |poll_option|
              expect(poll_option["poll_votes_count"]).to be_truthy
              if poll_option["id"] == answer_id
                expect(poll_option["is_selected"]).to be_truthy
              else
                expect(poll_option["poll_votes_count"]).to be_truthy
              end
            end
          else
            post["poll_options"].each do |poll_option|
              expect(poll_option["is_selected"]).to be_falsey
              expect(poll_option["poll_votes_count"]).to be_falsey
            end
          end
        else
          expect(post["title"]).to be_truthy
          expect(post["description"]).to be_truthy
        end
        expect(post["id"]).to be_truthy
        expect(post["counts"]).to be_truthy
      end
    end

    it "should invalidate older votes when vote is changed" do
      poll = Poll.order('created_at asc').first
      first_option_id = poll.poll_options.first.id
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: first_option_id }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["id"]).to eq(poll.id)
      expect(data["poll_options"].find { |item| item["id"] == poll.poll_options.first.id }["is_selected"]).to be_truthy
      expect(poll.poll_options.first.poll_votes.count).to eq(1)
      second_option_id = poll.poll_options.second.id
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: second_option_id }.to_json, headers: request_headers
      expect(poll.reload.poll_options.first.poll_votes.count).to eq(1)
      expect(poll.reload.poll_options.first.poll_votes.map(&:is_valid).length).to eq(1)
      expect(poll.reload.poll_options.first.poll_votes.map(&:is_valid)[0]).to be_falsey
      expect(poll.reload.poll_options.second.poll_votes.count).to eq(1)
      third_option_id = poll.poll_options.third.id
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: third_option_id }.to_json, headers: request_headers
      expect(poll.reload.poll_options.second.poll_votes.count).to eq(1)
      expect(poll.reload.poll_options.second.poll_votes.map(&:is_valid).length).to eq(1)
      expect(poll.reload.poll_options.second.poll_votes.map(&:is_valid)[0]).to be_falsey
      expect(poll.reload.poll_options.third.poll_votes.count).to eq(1)
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: first_option_id }.to_json, headers: request_headers
      expect(poll.reload.poll_options.third.poll_votes.count).to eq(1)
      expect(poll.reload.poll_options.third.poll_votes.map(&:is_valid).length).to eq(1)
      expect(poll.reload.poll_options.third.poll_votes.map(&:is_valid)[0]).to be_falsey
      expect(poll.reload.poll_options.first.poll_votes.count).to eq(2)
      expect(poll.reload.poll_options.first.poll_votes.order(created_at: :desc).first.is_valid).to be_truthy
      expect(poll.reload.poll_options.first.poll_votes.order(created_at: :desc).second.is_valid).to be_falsey
    end

    it "should get proper vote count when vote is changed" do
      poll = Poll.order('created_at asc').first
      first_option_id = poll.poll_options.first.id
      second_option_id = poll.poll_options.second.id
      third_option_id = poll.poll_options.third.id
      before_votes_count = poll.poll_options.first.poll_votes_count
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: first_option_id }.to_json, headers: request_headers
      first_poll = PollOption.find(first_option_id)
      after_votes_count = first_poll.poll_votes_count
      expect(after_votes_count - 1).to eq(before_votes_count)
      before_second_poll_votes_count = poll.poll_options.second.poll_votes_count
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: second_option_id }.to_json, headers: request_headers
      second_poll = PollOption.find(second_option_id)
      after_second_poll_votes_count = second_poll.poll_votes_count
      expect(after_second_poll_votes_count - 1).to eq(before_second_poll_votes_count)
      first_poll.poll_votes.each do |poll_vote|
        expect(poll_vote.is_valid).to be_falsey
      end
      expect(PollOption.find(first_option_id).poll_votes_count).to eq(before_votes_count)
      expect(second_poll.poll_votes.order("created_at desc").first.is_valid).to be_truthy

      before_third_poll_votes_count = PollOption.find(third_option_id).poll_votes_count
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: third_option_id }.to_json, headers: request_headers
      expect(PollOption.find(first_option_id).poll_votes_count).to eq(before_votes_count)
      expect(PollOption.find(second_option_id).poll_votes_count).to eq(before_second_poll_votes_count)
      expect(PollOption.find(third_option_id).poll_votes_count).to eq(before_third_poll_votes_count + 1)

      # second user voting
      user = User.order('created_at asc').second
      headers = DataHelper::HEADERS.merge(user.create_new_auth_token)
      post vote_api_v1_post_path(id: poll.id), params: { answer_id: first_option_id }.to_json, headers: headers
      first_poll = PollOption.find(first_option_id)
      expect(first_poll.poll_votes_count).to eq(before_votes_count + 1)
    end
  end

  describe "POSTS /api/v1/posts/:id/like" do
    it "should like an issue" do
      Like.destroy_all
      post = Issue.first
      post like_api_v1_post_path(id: post.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Post")
      expect(data["likeable_id"]).to eq(post.id)
      expect(post.reload.likes.count).to eq(1)
    end

    it "should like a poll" do
      Like.destroy_all
      post = Poll.first
      post like_api_v1_post_path(id: post.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Post")
      expect(data["likeable_id"]).to eq(post.id)
      expect(post.reload.likes.count).to eq(1)
    end

    it "should give error if comment is already liked" do
      post = Poll.first
      post like_api_v1_post_path(id: post.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Post")
      expect(data["likeable_id"]).to eq(post.id)
      expect(post.reload.likes.count).to eq(1)
      post like_api_v1_post_path(id: post.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("already_liked")
    end
  end

  describe "POSTS /api/v1/posts/:id/unlike" do
    it "should unlike post" do
      Like.destroy_all
      post = Issue.first
      post like_api_v1_post_path(id: post.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Post")
      expect(data["likeable_id"]).to eq(post.id)

      post unlike_api_v1_post_path(id: post.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(0)
      expect(data["likeable_type"]).to eq("Post")
      expect(data["likeable_id"]).to eq(post.id)
      expect(post.reload.likes.count).to eq(0)
    end
  end

  describe "GET /api/v1/posts/mine" do
    it "should get all posts of mine including commented and liked" do
      user = User.order('created_at asc').first
      count = user.my_posts.count
      get mine_api_v1_posts_url, headers: request_headers
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
      posts = Post.where(region_id: [user.assembly_constituency.id, user.parliamentary_constituency.id]).map(&:id)
      user_posts = Post.where(user_id: user.id, region_id: [user.assembly_constituency.id, user.parliamentary_constituency.id]).map(&:id)
      post_id = (posts - user_posts)[0]
      unless post_id.nil?
        post = Post.find(post_id)
        post.comments.build(text: "by user #{user.profile.name}", user_id: user.id)
        post.save
        get mine_api_v1_posts_url, headers: request_headers
        parsed_body = JSON.parse(response.body)
        data = parsed_body["data"]
        expect(data["activities"].count).to eq(user.my_posts.count)
        like = Like.new(user: user, likeable: post)
        like.save
        get mine_api_v1_posts_url, headers: request_headers
        parsed_body = JSON.parse(response.body)
        data = parsed_body["data"]
        count = user.my_posts.map do |activity|
          case activity.activable_type
          when 'PollVote'
            poll_vote_id = activity.activable_id
            post = PollVote.find(poll_vote_id).poll_option.poll
          when 'Comment'
            comment_id = activity.activable_id
            post = Comment.find(comment_id).post
          when 'Like'
            like_id = activity.activable_id
            like = Like.find(like_id)
            post = if like.likeable.class.name == "Comment"
                     Comment.find(like.likeable_id).post
                   else
                     Post.find(like.likeable_id)
                   end
          else
            # created the post
            post_id = activity.activable_id
            post = Post.find(post_id)
          end
          post.id
        end.uniq.count
        expect(data["activities"].count).to eq(count)
      end
    end
  end

  describe "GET /api/v1/posts/:id/poll_stats" do
    it "should raise error when id is not valid" do
      get api_v1_post_path(id: "something"), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["status"]).to eq 404
    end

    it "should raise error when group by is not in the valid list" do
      poll = Poll.first
      get poll_stats_api_v1_post_path(id: poll.id, resolution: 'something'), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq 422
    end
  end

  describe "GET /api/v1/posts/:id/comments" do
    it "should get newest and oldest comments for a post" do
      poll = Poll.first
      comment = create(:comment, post: poll, user: poll.user)
      reply_comment = create(:comment, post: poll, user: User.second)
      reply_comment.parent = comment
      reply_comment.save
      new_comment = create(:comment, post: poll, user: poll.user)
      get comments_api_v1_post_path(id: poll.id), headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["new_comments"].length).to eq(poll.comments.where(parent_id: nil).length)
      expect(data["old_comments"].length).to eq(poll.comments.where(parent_id: nil).length)
      expect(data["old_comments"][0]["id"]).to eq(comment.id)
      expect(data["new_comments"][0]["id"]).to eq(new_comment.id)
    end
  end

  describe "POST /api/v1/posts/id/flag" do
    it "should flag a post" do
      user = User.order('created_at asc').first
      poll = create(:poll)
      post flag_api_v1_post_path(id: poll.id, reason_to_flag: "Abusive post"), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["message"]).to eq("flagged")
      expect(Post.find(poll.id).flagged?).to be_truthy
    end

    it "should flag a post even with no reason" do
      user = User.order('created_at asc').first
      poll = Poll.where.not(user: user).first
      post flag_api_v1_post_path(id: poll.id, reason_to_flag: ""), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["message"]).to eq("flagged")
    end

    it "should not allow to flag a post once flagged" do
      user = User.order('created_at asc').first
      poll = Poll.where.not(user: user).first
      post flag_api_v1_post_path(id: poll.id, reason_to_flag: "Abusive post"), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["message"]).to eq("flagged")
      post flag_api_v1_post_path(id: poll.id, reason_to_flag: "Abusive post"), headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("already_flagged")
    end
  end

  describe "GET /api/v1/posts/national" do
    it "should get all national level posts" do
      get national_api_v1_posts_url, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["posts"].length).to eq(0)
      poll = create(:poll, region: nil, region_type: "", user: nil)
      get national_api_v1_posts_url, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["posts"].length).to eq(1)
      expect(data["posts"][0]["id"]).to eq(poll.id)
    end
  end
end
