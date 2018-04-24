module ApiResponseModels
  module Api
    module V1
      class PostData < PostsData
        include CommentsBuilder

        def self.fetch_from_stub
          if slug == "repair-of-durga-mata-mandir-road"
            file = "#{Rails.root}/app/models/api_response_models/api/v1/issue.json"
          else
            file = "#{Rails.root}/app/models/api_response_models/api/v1/poll.json"
          end
          json_string = File.read(file)
          item = JSON.parse(json_string, object_class: ApiResponseModels::CustomOstruct)
          post = new(item["question"], item["title"], item["description"], item["slug"], item["type"], item["category"], item["poll_options"], item["media"], item["replies"], item["created_by"], item["likes_count"], item["reply_count"], item["created_time"])
          post
        end

        def self.fetch_from_active_record(user_id, id)
          post = Post.find(id)
          poll_options = construct_poll_options(user_id, post)
          parent_comments = post.comments.where('parent_id is null')
          best_comments = parent_comments.sort_by(&:score).reverse[0..4]
          formatted_best_comments = []
          best_comments.each do |comment|
            formatted_best_comments << construct_parent_comment_and_replies(comment)
          end
          oldest_comments = parent_comments.sort_by(&:created_at)
          formatted_oldest_comments = []
          oldest_comments.each do |comment|
            formatted_oldest_comments << construct_parent_comment_and_replies(comment)
          end
          newest_comments = oldest_comments.reverse
          formatted_newest_comments = []
          newest_comments.each do |comment|
            formatted_newest_comments << construct_parent_comment_and_replies(comment)
          end
          comments = {
            "best": formatted_best_comments,
            "newest": formatted_newest_comments,
            "oldest": formatted_oldest_comments
          }

          media = post.attachments.map(&:media_obj)
          user = post.user
          ## adding if check since some posts created by admin don't have user id
          created_by = post.anonymous ? { name: "Anonymous" } : user.nil? ? { name: "Admin" } : { id: user.id, name: user.profile.name, image: user.profile.profile_pic_obj }
          created_time = post.created_at
          category = post.category.nil? ? nil : { id: post.category.id, name: post.category.name, slug: post.category.slug, image: post.category.image.url }
          new(post.id, post.question, post.title, post.description, post.type, category, poll_options, media, comments, created_by, { likes_count: post.likes_count, comments_count: post.comments_count }, created_time, 0, post.liked_by_user?(user_id), nil, post.poll_options_as_image)
        end

        def self.fetch_data(user_id, id, show_test_data = false)
          if show_test_data && (Rails.env.development? || Rails.env.test?)
            fetch_from_stub
          else
            fetch_from_active_record(user_id, id)
          end
        end
      end
    end
  end
end
