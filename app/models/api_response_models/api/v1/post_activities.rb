module ApiResponseModels
  module Api
    module V1
      class PostActivities < PostsData
        include ActiveModel::Model

        def self.set_activity_object_default_attrs(activity_obj, activity_id, action, resource, voted_poll_option_id, score, created_at, type)
          activity_obj.type = type
          activity_obj.activity_id = activity_id
          activity_obj.action = action
          activity_obj.actions = [{ action: action, created_at: created_at, score: score }]
          activity_obj.resource = resource
          activity_obj.voted_poll_option_id = voted_poll_option_id
          activity_obj.created_at = created_at
          activity_obj.score = score
          activity_obj
        end

        def self.parse_post_activity(user_id, activity, post_ids, activities)
          activity_id = activity.id
          action = activity.meta["meta_action"]
          resource = activity.meta["meta_object"]

          case activity.activable_type
          when 'PollVote'
            poll_vote_id = activity.activable_id
            post = Post.unscoped.find(PollVote.find(poll_vote_id).poll_option.poll_id)
          when 'Comment'
            comment_id = activity.activable_id
            post = Post.unscoped.find(Comment.find(comment_id).post_id)
            ## TODO fill the comments with users comments
          when 'Like'
            like_id = activity.activable_id
            like = Like.find(like_id)
            post = if like.likeable.class.name == "Comment"
                     Comment.find(like.likeable_id).post
                   else
                     Post.unscoped.find(like.likeable_id)
                   end
          else
            # created the post
            post_id = activity.activable_id
            post = Post.unscoped.find(post_id)
          end

          if post_ids.include?(post.id)
            activity_obj = activities.find { |item| item.post_id == post.id }
            activity_obj.actions << { action: action, created_at: activity.created_at, score: activity.score }
            [activity_obj, false]
          else
            post_ids << post.id
            activity_obj = CustomOstruct.new
            activity_obj = set_activity_object_default_attrs(activity_obj, activity_id, action, resource, nil, activity.score, activity.created_at, "post")
            activity_obj.post_id = post.id
            activity_obj.data = construct_post_object(user_id, post)
            [activity_obj, true]
          end
        end

        def self.parse_posts_activities(user_id, activities)
          posts_activities = []
          post_ids = []
          activities.each do |activity|
            new_activity, add = parse_post_activity(user_id, activity, post_ids, posts_activities)
            posts_activities << new_activity if add
          end
          posts_activities
        end

        def self.fetch_data(user_id, all_activities, offset, limit)
          activities = all_activities
          posts_activities = parse_posts_activities(user_id, activities)
          data = CustomOstruct.new
          data.offset = offset
          data.limit = limit
          data.activities = posts_activities.slice(offset, limit)
          data
        end
      end
    end
  end
end
