module ApiResponseModels
  module Api
    module V1
      class PostCommentsData
        include CommentsBuilder

        def self.fetch_from_active_record(post, user_id = nil)
          new_comments = post.comments.order("created_at desc").where(parent_id: nil)

          new_comments_formatted = []
          new_comments.each do |comment|
            formatted_comment = construct_comment_content(comment, user_id)
            formatted_comment_replies = []
            comment_replies = comment.children.order('created_at asc')
            comment_replies.each do |reply_comment|
              formatted_comment_replies << construct_comment_content(reply_comment, user_id)
            end
            formatted_comment.replies = formatted_comment_replies
            new_comments_formatted << formatted_comment
          end

          old_comments_formatted = new_comments_formatted.reverse
          [new_comments_formatted, old_comments_formatted]
        end

        def self.fetch_data(post, user_id)
          new_comments, old_comments = fetch_from_active_record(post, user_id)
          data = CustomOstruct.new
          data.new_comments = new_comments
          data.old_comments = old_comments
          data
        end
      end
    end
  end
end
