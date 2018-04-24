module ApiResponseModels
  module Api
    module V1
      class CommentData
        include CommentsBuilder

        attr_accessor :id, :author, :text, :counts, :comments

        def self.fetch_from_active_record(comment, offset, limit)
          construct_parent_comment_and_replies(comment, offset, limit)
        end

        def self.fetch_data(id, offset, limit)
          comment = Comment.find(id)
          fetch_from_active_record(comment, offset, limit)
        end
      end
    end
  end
end
