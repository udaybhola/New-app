module Api
  module V1
    class CandidatesController < ApiV1Controller
      before_action :validate_params

      def show
        constituency = Constituency.find(@constituency_id)
        @candidate = ApiResponseModels::Api::V1::CandidateProfileData.fetch_data(@candidate_id, constituency, @user)
      end

      def candidatures
        @candidatures = ApiResponseModels::Api::V1::CandidatureListData.fetch_data(@candidate_id)
      end

      def posts
        candidate = Candidate.find(@candidate_id)
        post_activities_of_candidate = candidate.profile.nil? || candidate.profile.user.nil? ? Activity.none : candidate.profile.user.my_posts
        @posts_activities = ApiResponseModels::Api::V1::PostActivities.fetch_data(post_activities_of_candidate.empty? ? nil : candidate.profile.user.id, post_activities_of_candidate, @offset, @limit)
      end

      def validate_params
        @params = params.permit(:id, :constituency_id, :offset, :limit)
        @constituency_id = @params["constituency_id"]
        @candidate_id = @params["id"]
        @limit = @params["limit"] || 10
        @offset = @params["offset"] || 0
        # raise Error::CustomError unless [user.assembly_constituency.id, user.parliamentary_constituency].include?(@constituency_id)
      end
    end
  end
end
