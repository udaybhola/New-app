module Api
  module V1
    class InfluencersController < ApiV1Controller
      before_action :validate_update_params, only: [:update]
      before_action :validate_params, only: [:index, :search]
      before_action :set_offset_and_limit

      def index
        get_all_data
      end

      def search
        query_param = @params["query"]
        raise Error::CustomError if query_param.nil?
        get_all_data(query_param)
        render 'index'
      end

      def show
        begin
          user = User.find(params.permit(:id)["id"])
        rescue StandardError
          Rails.logger.debug "user not found with id: #{params.permit(:id)['id']}"
        ensure
          user ||= @user
        end
        @influencer = ApiResponseModels::Api::V1::InfluencerProfileData.fetch_data(user, current_user_id)
      end

      def update
        profile = @user.profile
        constituency_id = @profile_params.delete("constituency_id")
        new_profile_params = @profile_params
        new_profile_params[:contact] = (profile[:contact] || {}).merge(@profile_params[:contact] || {})

        profile_pic = new_profile_params["profile_pic"]
        unless profile_pic.to_s.empty?
          profile.profile_pic.file&.delete
          preloaded = Cloudinary::PreloadedFile.new(profile_pic)
          raise "Invalid upload signature" unless preloaded.valid?
        end

        cover_photo = new_profile_params["cover_photo"]
        unless cover_photo.to_s.empty?
          profile.cover_photo.file&.delete
          preloaded = Cloudinary::PreloadedFile.new(cover_photo)
          raise "Invalid upload signature" unless preloaded.valid?
        end

        profile.update_attributes(new_profile_params)
        update_candidate_params(@user) unless @user.profile.candidate.nil?
        update_user_params(constituency_id) unless constituency_id.nil?
        @influencer = ApiResponseModels::Api::V1::InfluencerProfileData.fetch_data(@user.reload, current_user_id)
        render 'show'
      end

      def activity
        user_id = params.permit(:id)["id"]
        user = User.find(user_id)
        all_user_activities = if user_id != current_user_id
                                user.public_activities.order("created_at desc")
                              else
                                user.activities.order("created_at desc")
                              end
        request_type = params.permit(:request_type)["request_type"]
        @all_activities = ApiResponseModels::Api::V1::AllUserActivities.fetch_data(request_type == "influencer" ? nil : current_user_id, all_user_activities, @offset, @limit)
      end

      ## used in app for influencer/profile(activity) screen
      def posts
        posts = @user.posts.order('created_at desc')
        @data = ApiResponseModels::Api::V1::PostsData.fetch_data(current_user_id, posts, "", nil, @offset, @limit)
      end

      def scorelog
        all_user_activities = @user.activities.order("created_at desc")
        @all_activities = ApiResponseModels::Api::V1::ScoreLogData.fetch_data(current_user_id, all_user_activities, @offset, @limit)
      end

      private

      def get_all_data(_query_param = nil)
        sort_by = @params["sort_by"] || "votes"
        state_id = @params["state_id"]
        state_id = nil if state_id.blank?
        @influencers = if Rails.env.test?
                         ApiResponseModels::Api::V1::InfluencersData.fetch_data(@constituency_id, sort_by, _query_param, @offset, @limit)
                       else
                         Leaderboards.influencers.popular_influencers(constituency_id: @constituency_id, state_id: state_id)
                       end
      end

      def validate_update_params
        @profile_params = params.require(:influencer).permit(:name, :profile_pic, :cover_photo, :gender, :religion_id, :caste_id, :education, :qualification, :profession_id, :constituency_id, 'date_of_birth(1i)', 'date_of_birth(2i)', 'date_of_birth(3i)', contact: [:phone, :email, :pincode, :twitter, :facebook, :website], financials: [:income, :assets, :liabilities], civil_record: [:criminal_cases], status: [:registered_to_vote])

        @candidate_profile_params = params.require(:influencer).permit(:name, :profile_pic, :cover_photo, :gender, :religion_id, :caste_id, :education, :qualification, :profession_id, 'date_of_birth(1i)', 'date_of_birth(2i)', 'date_of_birth(3i)', contact: [:facebook, :twitter, :website, :phone, :phone2, :email], financials: [:income, :assets, :liabilities], civil_record: [:criminal_cases], status: [:registered_to_vote])
        @party_abbr = params.require(:influencer).permit(:party_abbr)
      end

      def update_candidate_params(user)
        profile = user.profile
        new_candidate_profile_params = @candidate_profile_params
        new_candidate_profile_params[:contact] = (profile[:contact] || {}).merge(@candidate_profile_params[:contact] || {})
        new_candidate_profile_params[:financials] = (profile[:financials] || {}).merge(@candidate_profile_params[:financials] || {})
        new_candidate_profile_params[:civil_record] = (profile[:civil_record] || {}).merge(@candidate_profile_params[:civil_record] || {})
        profile.update_attributes(new_candidate_profile_params)
        return if @party_abbr.empty?
        candidate = profile.candidate
        latest_candidature = candidate.candidatures.order("created_at desc").first
        latest_candidature.party = Party.find_by(abbreviation: @party_abbr["party_abbr"])
        latest_candidature.save!
      end

      def update_user_params(constituency_id)
        @user.constituency_id = constituency_id
        @user.save!
        Leaderboards.influencers.register_influencer_score(@user) unless Rails.env.test?
      end

      def set_offset_and_limit
        @params = params.permit(:offset, :limit, :state_id)
        @offset = @params["offset"] || 0
        @limit = @params["limit"] || 100
      end

      def validate_params
        @params = params.permit(:id, :constituency_id, :query, :state_id)

        @constituency_id = @params["constituency_id"]
        @candidate_id = @params["id"]
        raise Error::CustomError if @constituency_id.nil?
        # raise Error::CustomError unless [@user.assembly_constituency.id, @user.parliamentary_constituency].include?(@constituency_id)
      end
    end
  end
end
