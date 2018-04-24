module Api
  module V1
    class CommentsController < Api::V1::ApiV1Controller
      before_action :validate_params
      include FlagHelper

      def create
        post_id = @params["post_id"]
        text = @params["text"]
        post = Post.find(post_id)
        comment_params = { user: @user, post: post, text: text }
        @comment = post.comments.new comment_params
        unless @comment.save!
          render json: {
            error: "internal_server_error",
            message: post.errors.messages,
            status: 500
          }
        end
      end

      def reply
        post_id = @params["post_id"]
        text = @params["text"]
        post = Post.find(post_id)
        comment = Comment.find(@params["id"])
        comment_params = { user: @user, post: post, text: text, parent: comment }
        @comment = post.comments.new comment_params
        unless @comment.save!
          render json: {
            error: "internal_server_error",
            message: post.errors.messages,
            status: 500
          }
        end
      end

      def like
        comment_id = @params["id"]
        like = Like.find_by(likeable_id: comment_id, user: @user)
        render json: { error: "already_liked" } unless like.nil?
        return unless like.nil?
        comment = Comment.find(comment_id)
        like = comment.like(@user)

        unless like.errors.messages.empty?
          render json: {
            error: "internal_server_error",
            message: like.errors.messages,
            status: 500
          }
        end

        @like = {
          likeable_id: like.likeable_id,
          likeable_type: like.likeable_type,
          likes_count: comment.likes.count
        }
      end

      def unlike
        comment = Comment.find(@params["id"])
        like = comment.unlike(@user)

        unless like.errors.messages.empty?
          render json: {
            error: "internal_server_error",
            message: like.errors.messages,
            status: 500
          }
        end

        @like = {
          likeable_id: like.likeable_id,
          likeable_type: like.likeable_type,
          likes_count: comment.likes.count
        }
      end

      def replies
        offset = params.permit(:offset)[:offset] || 0
        limit = params.permit(:limit)[:limit] || 5
        id = @params["id"]
        comment = ApiResponseModels::Api::V1::CommentData.fetch_data(id, offset, limit)
        @comment_data = comment.comments
      end

      def flag
        @flaggable = Comment.find(params.permit(:id)["id"])
        @reason_to_flag = params.permit(:reason_to_flag)["reason_to_flag"]
        flag_resource
      end

      private

      def validate_params
        @params = params.permit(:post_id, :text, :id)
      end
    end
  end
end
