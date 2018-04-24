module ApiResponseModels
  module Api
    module V1
      class ScoreLogData < AllUserActivities
        def self.construct_post_object(_user_id = nil, post)
          post_object = CustomOstruct.new
          post_object.id = post.id
          post_object.title = post.title
          post_object.question = post.question
          post_object.type = post.type
          post_object
        end

        def self.fetch_data(user_id, all_activities, offset, limit)
          activities = all_activities.limit(limit).offset(offset)
          all_activities = parse_activities(user_id, activities)
          data = CustomOstruct.new
          data.offset = offset
          data.limit = limit
          data.activities = all_activities
          data
        end
      end
    end
  end
end
