module ApiResponseModels
  module Api
    module V1
      class PostsData
        include ActiveModel::Model
        include CommentsBuilder
        attr_accessor :id, :question, :title, :description, :type, :category, :poll_options, :media, :comments, :created_by, :counts, :created_time, :score, :is_liked_by_me, :constituency, :poll_options_as_image

        def initialize(id, question, title, description, type, category, poll_options, media, comments, created_by, counts, created_time, score = 0, is_liked_by_me = false, constituency = nil, poll_options_as_image = false)
          @id = id
          @question = question
          @title = title
          @description = description
          @type = type
          @category = category
          @poll_options = poll_options
          @media = media
          @comments = comments
          @created_by = created_by
          @counts = counts
          @created_time = created_time
          @score = score
          @is_liked_by_me = is_liked_by_me
          @constituency = constituency
          @poll_options_as_image = poll_options_as_image
        end

        def self.fetch_from_stub
          posts = []
          json_string = File.read("#{Rails.root}/app/models/api_response_models/api/v1/posts.json")
          fetch_data = JSON.parse(json_string, object_class: ApiResponseModels::CustomOstruct)
          fetch_data.each do |item|
            posts << new(item["id"], item["question"], item["title"], item["description"], item["type"], item["category"], item["poll_options"], item["media"], item["comments"], item["created_by"], { likes_count: item["likes_count"], comments_count: item["comments_count"] }, item["created_time"])
          end
          posts
        end

        def self.construct_poll_option(poll_options, poll_option, poll_vote_poll_option_id)
          poll_votes = poll_option["poll_votes_count"]
          ## if voted for poll only then show percentage
          if poll_vote_poll_option_id.nil?
            poll_option["poll_votes_count"] = nil
          else
            poll_option["percentage"] = if poll_options.map { |option| option["poll_votes_count"] }.reduce(:+).zero?
                                          0
                                        else
                                          (poll_option["poll_votes_count"].to_f / poll_options.map { |option| option["poll_votes_count"] }.reduce(:+).to_f) * 100.to_f
                                        end
            poll_option["poll_votes_count"] = poll_votes
            poll_option["is_selected"] = poll_vote_poll_option_id.nil? ? false : poll_vote_poll_option_id == poll_option["id"]
          end
          poll_option
        end

        def self.construct_poll_options(user_id, post)
          poll_votes = PollVote.where(poll_option_id: post.poll_options.map(&:id), user_id: user_id, is_valid: true)
          poll_vote_poll_option_id = poll_votes.count.positive? ? poll_votes.first.poll_option.id : nil
          poll_options = post.poll_options.order("position asc, created_at asc").map{|item| {id: item.id, answer: item.answer, position: item.position, poll_votes_count: item.poll_votes.valid.count, image: item.image_obj}}.as_json
          poll_options.map { |poll_option| construct_poll_option(poll_options, poll_option, poll_vote_poll_option_id) }
          poll_options
        end

        def self.construct_post_object(user_id, post)
          media = post.attachments.map(&:media_obj)
          poll_options = construct_poll_options(user_id, post)
          commented_user_candidates = Profile.where(user_id: post.comments.map(&:user_id)).where.not(candidate_id: nil).map(&:user_id)

          all_comments = Comment.where(user_id: commented_user_candidates)
          comments = []
          all_comments.each do |comment|
            comments << construct_comment_content(comment)
          end

          user = post.user
          created_by = post.anonymous ? { name: "Anonymous" } : !user.nil? ? { id: user.id, name: user.profile.name,
                                                                               image: user.profile.profile_pic_obj } : { name: "Admin" }
          created_time = post.created_at
          if post.category
            category = { id: post.category.id, name: post.category.name,
                         slug: post.category.slug, image: post.category.image }
          end
          constituency = {id: post.region.id, name: post.region.name}  unless post.region.nil?
          new(post.id, post.question, post.title, post.description,
              post.type, category, poll_options, media, comments,
              created_by,
              { likes_count: post.likes_count,
                comments_count: post.comments_count }, created_time, 0, post.liked_by_user?(user_id), constituency, post.poll_options_as_image)
        end

        def self.fetch_from_active_record(user_id, posts, _filter_param, _offset, _limit)
          arranged_data = []
          if _filter_param
            category = Category.find_by(slug: _filter_param)
            posts = posts.where("posts.category_id = '#{category.id}'")
          end
          issues = posts.group_by(&:type)["Issue"]
          polls = posts.group_by(&:type)["Poll"]
          no_of_issues = issues.count if issues
          no_of_polls = polls.count if polls

          no_of_issues ||= 0
          no_of_polls ||= 0

          posts.each do |post|
            arranged_data << construct_post_object(user_id, post)
          end
          [no_of_issues || 0, no_of_polls || 0, arranged_data]
        end

        def self.fetch_data(user_id, posts, _sort_param, filter_param, offset, limit, show_test_data = false)
          no_of_issues = 0
          no_of_polls = 0
          arranged_data = []
          if show_test_data && (Rails.env.development? || Rails.env.test?)
            arranged_data = fetch_from_stub
          else
            no_of_issues, no_of_polls, arranged_data =
              fetch_from_active_record(user_id, posts, filter_param, offset, limit)
            arranged_data = case _sort_param
                            when 'score'
                              arranged_data.sort_by(&:score).reverse
                            when 'likes'
                              arranged_data
                            .sort_by { |item| item.counts["likes_count"] }.reverse
                            else
                              arranged_data.sort_by(&:created_time).reverse
                            end
          end
          data = CustomOstruct.new
          data.offset = offset
          data.limit = limit
          data.no_of_issues = no_of_issues
          data.no_of_polls = no_of_polls
          data.posts = arranged_data
          data
        end

        def self.fetch_constituency_data(user_id, constituency, _sort_param, filter_param, offset, limit, show_test_data = false)
          no_of_issues = 0
          no_of_polls = 0
          arranged_data = []
          if show_test_data && (Rails.env.development? || Rails.env.test?)
            arranged_data = fetch_from_stub
          else
            posts = Post.state(constituency.country_state.id).where.not(user_id: nil).order('created_at desc').offset(offset).limit(limit)
            no_of_issues, no_of_polls, arranged_data =
              fetch_from_active_record(user_id, posts, filter_param, offset, limit)
          end
          data = CustomOstruct.new
          data.offset = offset
          data.limit = limit
          data.no_of_issues = no_of_issues
          data.no_of_polls = no_of_polls
          data.posts = arranged_data
          data
        end
      end
    end
  end
end
