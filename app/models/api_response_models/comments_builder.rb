module ApiResponseModels
  module CommentsBuilder
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def construct_parent_comment_and_replies(parent_comment, offset = 0, limit = 5)
        new_comment = construct_comment_content(parent_comment)
        new_comment.comments = CustomOstruct.new
        new_comment.comments.offset = offset
        new_comment.comments.limit = limit
        child_comments = parent_comment.children.offset(offset).limit(limit).order('created_at asc')
        new_comment.comments.data = []
        child_comments.each do |child_comment|
          new_comment.comments.data << construct_comment_content(child_comment)
        end
        new_comment
      end

      def construct_comment_content(comment, user_id = nil)
        new_comment = CustomOstruct.new
        new_comment.id = comment.id
        author = { "name": comment.user.profile.name, "image": comment.user.profile.profile_pic_obj }
        new_comment.author = author
        new_comment.text = comment.text
        new_comment.counts = { likes_count: comment.likes_count, comments_count: comment.children.count }
        new_comment.created_time = comment.created_at
        new_comment.is_liked_by_me = comment.liked_by_user?(user_id)
        new_comment
      end
    end
  end
end
