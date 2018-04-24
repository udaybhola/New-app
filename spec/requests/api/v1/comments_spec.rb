require 'rails_helper'

RSpec.describe "Comments spec", type: :request do
  before(:each) do
    data_helper_create_data_set
  end

  describe "POST /api/v1/posts/comments" do
    it "Should create new comment for a post with valid params" do
      text = "Hey, thats cool"
      post = Issue.first
      post.comments.destroy_all
      post api_v1_post_comments_path(post_id: post.id), params: { text: text }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["text"]).to eq(text)
      expect(data["likes_count"]).to eq(0)
      expect(data["comments_count"]).to eq(0)
      expect(data["author"]["name"]).to be_truthy
      expect(data["author"]["image"]).to be_truthy
      expect(data["id"]).to be_truthy
      expect(post.comments.count).to eq(1)
      comment = Comment.find(data["id"])
      expect(comment.text).to eq(text)
      expect(comment.parent_id).to be_falsey
    end

    it "Should not create comment for a post with invalid params" do
      post = Issue.first
      post.comments.destroy_all
      post api_v1_post_comments_path(post_id: post.id), params: {}.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data).to be_falsey
      expect(post.comments.count).to eq(0)
    end
  end

  describe "POST /api/v1/posts/:post_id/comments/:id/reply" do
    it "should be able to reply to an existing comment" do
      text = "Hey, thats cool"
      post = Issue.first
      post.comments.destroy_all
      post api_v1_post_comments_path(post_id: post.id), params: { text: text }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["text"]).to eq(text)
      expect(data["likes_count"]).to eq(0)
      expect(data["comments_count"]).to eq(0)
      expect(data["author"]["name"]).to be_truthy
      expect(data["author"]["image"]).to be_truthy
      expect(data["id"]).to be_truthy
      expect(post.comments.count).to eq(1)
      comment = Comment.find(data["id"])
      expect(comment.text).to eq(text)
      expect(comment.parent_id).to be_falsey

      reply = "Do you really think its cool?"
      post reply_api_v1_post_comment_path(post_id: post.id, id: comment.id), params: { text: reply }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["text"]).to eq(reply)
      expect(data["likes_count"]).to eq(0)
      expect(data["comments_count"]).to eq(0)
      expect(data["author"]["name"]).to be_truthy
      expect(data["author"]["image"]).to be_truthy
      parent_comment = comment
      comment = Comment.find(data["id"])
      expect(comment.text).to eq(reply)
      expect(post.comments.count).to eq(2)
      expect(comment.parent_id).to be_truthy
      expect(comment.comments_count).to eq(0)
      expect(parent_comment.reload.comments_count).to eq(1)
    end

    it "should not be able to reply to a comment" do
      text = "Hey, thats cool"
      post = Issue.first
      post.comments.destroy_all
      post api_v1_post_comments_path(post_id: post.id), params: { text: text }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["text"]).to eq(text)
      expect(data["likes_count"]).to eq(0)
      expect(data["comments_count"]).to eq(0)
      expect(data["author"]["name"]).to be_truthy
      expect(data["author"]["image"]).to be_truthy
      expect(data["id"]).to be_truthy
      expect(post.comments.count).to eq(1)
      comment = Comment.find(data["id"])
      expect(comment.text).to eq(text)
      expect(comment.parent_id).to be_falsey

      reply = "Do you really think its cool?"
      post reply_api_v1_post_comment_path(post_id: post.id, id: comment.id), params: { text: reply }.to_json, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["text"]).to eq(reply)
      expect(data["likes_count"]).to eq(0)
      expect(data["comments_count"]).to eq(0)
      expect(data["author"]["name"]).to be_truthy
      expect(data["author"]["image"]).to be_truthy
      parent_comment = comment
      comment = Comment.find(data["id"])
      expect(comment.text).to eq(reply)
      expect(post.comments.count).to eq(2)
      expect(comment.parent_id).to be_truthy
      expect(comment.comments_count).to eq(0)
      expect(parent_comment.reload.comments_count).to eq(1)

      second_level_reply = "Yea?, whats the problem?"
      post reply_api_v1_post_comment_path(post_id: post.id, id: comment.id), params: { text: second_level_reply }.to_json, headers: request_headers
      data = JSON.parse(response.body)
      expect(data["status"]).to eq(500)
      expect(data["error"]).to eq("internal_server_error")
      expect(data["message"]).to eq("Validation failed: Parent trying to add a comment for a reply")
    end
  end

  describe "POSTS /api/v1/posts/:post_id/comments/:id/like" do
    it "should like a comment for an issue" do
      post = Issue.first
      comment = create(:comment, post: post)
      post like_api_v1_post_comment_path(post_id: post.id, id: comment.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Comment")
      expect(data["likeable_id"]).to eq(comment.id)
      expect(comment.reload.likes.count).to eq(1)
    end

    it "should like a comment for a poll" do
      post = Poll.first
      comment = create(:comment, post: post)
      post like_api_v1_post_comment_path(post_id: post.id, id: comment.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Comment")
      expect(data["likeable_id"]).to eq(comment.id)
      expect(comment.reload.likes.count).to eq(1)
    end
  end

  describe "POSTS /api/v1/posts/:post_id/comments/:id/unlike" do
    it "should unlike comment" do
      post = Issue.first
      comment = create(:comment, post: post)
      post like_api_v1_post_comment_path(post_id: post.id, id: comment.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(1)
      expect(data["likeable_type"]).to eq("Comment")
      expect(data["likeable_id"]).to eq(comment.id)

      post unlike_api_v1_post_comment_path(post_id: post.id, id: comment.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["likes_count"]).to eq(0)
      expect(data["likeable_type"]).to eq("Comment")
      expect(data["likeable_id"]).to eq(comment.id)
      expect(comment.reload.likes.count).to eq(0)
    end
  end

  describe "GET /api/v1/posts/:post_id/comments/:id/replies" do
    it "should fetch replies for a comment" do
      post = Issue.first
      comment = create(:comment, post: post, user: User.first)
      get replies_api_v1_post_comment_path(post_id: post.id, id: comment.id), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["offset"]).to eq(0)
      expect(data["limit"]).to eq(5)
      expect(data["data"]).to be_truthy
      expect(data["data"].count).to eq(0)
    end

    it "should fetch replies for a comment using offset and limit" do
      post = Issue.first
      comment = create(:comment, post: post, user: User.first)
      comments = []
      5.times do
        comments << create(:comment, post: post, user: User.first)
      end
      comment.children = comments
      comment.save!
      get replies_api_v1_post_comment_path(post_id: post.id, id: comment.id), params: { offset: 2, limit: 2 }, headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["offset"]).to eq(2.to_s)
      expect(data["limit"]).to eq(2.to_s)
      expect(data["data"]).to be_truthy
      expect(data["data"].count).to eq(2)
    end
  end

  describe "POST /api/v1/posts/comments/id/flag" do
    it "should flag a post" do
      post = Issue.first
      comment = create(:comment, post: post, user: User.first)
      post flag_api_v1_post_comment_path(post_id: post.id, id: comment.id, reason_to_flag: "Abusive Comment"), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["message"]).to eq("flagged")
    end

    it "should not allow to flag a comment once flagged" do
      post = Issue.first
      comment = create(:comment, post: post, user: User.first)
      post flag_api_v1_post_comment_path(post_id: post.id, id: comment.id, reason_to_flag: "Abusive Comment"), headers: request_headers
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["message"]).to eq("flagged")
      post flag_api_v1_post_comment_path(post_id: post.id, id: comment.id, reason_to_flag: "Abusive Comment"), headers: request_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("already_flagged")
    end
  end
end
