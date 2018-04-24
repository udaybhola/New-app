module Api
  module V1
    # rubocop:disable ClassLength
    class PostsController < Api::V1::ApiV1Controller
      before_action :validate_request_params, only: [:index, :mine, :national]
      before_action :validate_post_create, only: [:create]
      before_action :validate_poll_stats_request_params, only: [:poll_stats]
      include FlagHelper

      def index
        raise Error::CustomError.new(nil, nil, "need to pass constituency_id param") if @constituency_id.nil?

        # values will be any one of categories - educational, environmental, financial, infrastructure, health, national (where he has commented or created)
        filter_param = @params["filter_by"]
        # values will be  desc(newest), score(trending), most_likes
        sort_param = @params["sort_by"] || 'score'
        offset = @params["offset"] || 0
        limit = @params["limit"] || 10

        constituency = Constituency.find(@constituency_id)
        @data = if Rails.env.test? || sort_param == "newest"
                  ApiResponseModels::Api::V1::PostsData.fetch_constituency_data(current_user_id, constituency, sort_param, filter_param, offset, limit)
                elsif sort_param == "score"
                  Influx::EntityInstances.post_scoring_measurement.trending(
                    user_id: current_user_id,
                    constituency_id: constituency.parent.id
                  )
                end
      end

      def show
        id = params.permit(:id)[:id]
        @post = ApiResponseModels::Api::V1::PostData.fetch_data(current_user_id, id)
      end

      def create
        anonymous = @params["anonymous"] || false
        if @type == "issue"
          title = @params["title"]
          description = @params["description"]
          @post = Issue.new(user: @user, region: @constituency, category: @category || nil, title: title, description: description, anonymous: anonymous)
        else
          question = @params["question"]
          @post = Poll.new(user: @user, region: @constituency, category: @category || nil, question: question, anonymous: anonymous)
          poll_answers = params.permit(:answers => [])["answers"]
          poll_answers.each_with_index do |answer, index|
            @post.poll_options.build(answer: answer, position: index)
          end
        end

        media = params.permit(:media => [])["media"]
        if !media.nil? && !media.empty?
          all_media = []
          media.each do |file|
            preloaded = Cloudinary::PreloadedFile.new(file)
            raise "Invalid upload signature" unless preloaded.valid?
            all_media << Attachment.new(media: file)
          end
          @post.attachments = all_media
        end

        unless @post.save!
          render json: {
            error: "internal_server_error",
            message: @post.errors.messages,
            status: 500
          }
        end

        @post = ApiResponseModels::Api::V1::PostData.fetch_data(current_user_id, @post.id)
        render 'show'
      end

      def vote
        post_id = params.permit(:id)["id"]
        answer_id = params.permit(:answer_id)["answer_id"]
        post = Post.find(post_id)
        poll_options = post.poll_options
        selected_poll_option = poll_options.find(answer_id)
        poll_vote = PollVote.new(user: @user, poll_option: selected_poll_option, is_valid: true)

        unless poll_vote.save!
          render json: {
            error: "internal_server_error",
            message: @poll_vote.errors.messages,
            status: 500
          }
        end

        @post = ApiResponseModels::Api::V1::PostData.fetch_data(current_user_id, post.id)
      end

      def like
        post_id = params.permit(:id)["id"]
        like = Like.find_by(likeable_id: post_id, user: @user)
        render json: { error: "already_liked" } unless like.nil?
        return unless like.nil?

        post = Post.find(post_id)
        like = post.like(@user)

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
          likes_count: post.likes.count
        }
      end

      def unlike
        post = Post.find(params.permit(:id)["id"])
        like = post.unlike(@user)

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
          likes_count: post.likes.count
        }
      end

      ## used in app for my issues screen
      def mine
        post_activities_of_user = @user.my_posts
        offset = @params["offset"] || 0
        limit = @params["limit"] || 100
        @posts_activities = ApiResponseModels::Api::V1::PostActivities.fetch_data(current_user_id, post_activities_of_user, offset.to_i, limit.to_i)
      end

      def poll_stats
        @stats = Influx::EntityInstances.poll_vote_scoring_measurement.poll_stats(
          poll_id: @poll.id,
          resolution: @resolution
        )
      end

      def comments
        post = Post.find(params.permit(:id)["id"])
        @comments_data = ApiResponseModels::Api::V1::PostCommentsData.fetch_data(post, current_user_id)
      end

      def flag
        @flaggable = Post.find(params.permit(:id)["id"])
        @reason_to_flag = params.permit(:reason_to_flag)["reason_to_flag"]
        flag_resource
      end

      def national
        offset = @params["offset"] || 0
        limit = @params["limit"] || 10
        posts = Post.national.featured.offset(offset.to_i).limit(limit.to_i)
        @data = ApiResponseModels::Api::V1::PostsData.fetch_data(current_user_id, posts, nil, nil, offset, limit)
        render 'index'
      end

      private

      def validate_poll_stats_request_params
        @params = params.permit(:id, :resolution)
        @poll = Poll.find(@params["id"])
        @resolution = @params["resolution"] || ''
        valid_resolutions = %w[last_24_hours last_week last_month since_the_beginning]
        raise Error::CustomError.new(nil, nil, "resolution param should be one of #{valid_resolutions}") unless valid_resolutions.include?(@resolution)

        raise Error::CustomError.new(nil, nil, "User should be logged in") if current_user_id.blank?
        raise Error::CustomError.new(nil, nil, "User should have voted for this poll") unless @poll.has_user_voted?(current_user_id)
      end

      def validate_request_params
        params.delete(:post)
        @params = params.permit(:filter_by, :sort_by, :offset, :limit, :constituency_id)

        sort_by = @params["sort_by"]

        @constituency_id = @params["constituency_id"]

        raise Error::CustomError if sort_by && !%w[newest score likes].include?(sort_by)
      end

      def validate_post_create
        # validate that type should be one of issue, poll
        # validate if type is poll, poll answers are present are not
        # validate constituency && category or not
        @params = params.permit(:type, :title, :description, :constituencyId, :category, :media, :answers, :question, :anonymous)
        @type = @params["type"]

        raise Error::CustomError unless Post.types.include?(@type)

        @constituency = Constituency.find(params.permit(:constituencyId)["constituencyId"])
        @category = Category.find(params.permit(:category)["category"]) unless params.permit(:category)["category"].nil?
      end
    end
    # rubocop:enable ClassLength
  end
end
