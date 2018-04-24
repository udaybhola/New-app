module Api
  module V1
    class CandidaturesController < ApiV1Controller
      before_action :validate_params
      before_action :validate_vote, only: [:vote, :cancel_vote]

      def index
        get_all_data
      end

      def search
        query_param = @params["query"]
        raise Error::CustomError if query_param.nil?
        get_all_data(query_param)
        render 'index'
      end

      def manifesto
        @manifesto = @candidature.manifesto
      end

      def vote
        raise Error::CustomError.new(500, "internal_server_error", "Already voted for same candidate") if @user.already_voted?(@candidature)

        previous_vote = @user.previous_vote(@candidature.election)
        vote = CandidateVote.new(candidature: @candidature, user: @user, election: @candidature.election, is_valid: true, previous_vote: previous_vote)
        unless vote.save!
          render json: {
            error: "internal_server_error",
            message: vote.errors.messages,
            status: 500
          }
        end

        @party_and_support_info = ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(@user.profile, @candidature.candidate, @candidature.constituency, @user)
      end

      def cancel_vote
        if @candidature.cancel_vote(current_user_id).nil?
          render json: {
            error: "internal_server_error",
            message: @candidature.errors.messages,
            status: 500
          }
        end

        @party_and_support_info = ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(@user.profile, @candidature.candidate, @candidature.constituency, @user)
      end

      def messages
        @messages = @candidature.messages
      end

      def message
        title = params.permit(:title)["title"]
        raise Error::CustomError if title.nil?

        @message = Message.new(title: title, candidature: @candidature)
        media = params.permit(:media)["media"]
        preloaded = Cloudinary::PreloadedFile.new(media)
        raise "Invalid upload signature" unless preloaded.valid?

        @message.attachment = Attachment.new(media: media)

        unless @message.save!
          render json: {
            error: "internal_server_error",
            message: @message.errors.messages,
            status: 500
          }
        end
      end

      def commented_issues
        # values will be any one of categories - educational, environmental, financial, infrastructure, health, national (where he has commented or created)
        filter_param = @params["filter_by"]
        # values will be  desc(newest), score(trending), most_likes
        sort_param = @params["sort_by"]
        offset = @params["offset"] || 0
        limit = @params["limit"] || 10
        posts = @candidature.commented_posts
        @data = ApiResponseModels::Api::V1::PostsData.fetch_data(current_user_id, posts, sort_param, filter_param, offset, limit)
      end

      def current_voted_candidate
        constituency_id = params.permit(:constituency_id)["constituency_id"]
        constituency = Constituency.find(constituency_id)
        candidate_vote = @user.candidate_votes.valid.where(election: constituency.current_election).first

        unless candidate_vote.nil? 
          candidature = candidate_vote.candidature
          @party_and_support_info  = ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(@user.profile, candidature.candidate, candidature.constituency, @user)
        else
           @party_and_support_info = {
            party_name: "", 
            candidature: "", 
            candidate_vote_count: "", 
            supported_user_info: {}, 
            vote_percentage: ""
          }
        end
        render 'vote'
      end

      private

      def get_all_data(query_param = nil)
        sort_by = @params["sort_by"]
        state_id = @params["state_id"]
        state_id = nil if state_id.blank?
        @candidates = if Rails.env.test?
                        ApiResponseModels::Api::V1::CandidatesData.fetch_data(current_user_id, @constituency_id, sort_by, query_param)
                      else
                        Leaderboards.candidatures.popular_candidatures(user_id: current_user_id,
                                                                       constituency_id: @constituency_id,
                                                                       sort_by: sort_by,
                                                                       state_id: state_id)
                      end
      end

      def validate_params
        params.delete(:candidature)
        @params = params.permit(:id, :constituency_id, :sort_by, :query, :state_id)
        @constituency_id = @params["constituency_id"]
        @constituency_id = nil if @constituency_id.blank?
        @candidature = Candidature.find(@params["id"]) unless @params["id"].nil?
      end

      def validate_cancel_and_revote
        validate_vote_same_constituency
      end

      def validate_vote
        validate_already_voted
        validate_vote_same_constituency
      end

      def validate_vote_same_constituency
          ## check if the user and candidature are in same constituency before even proceeding to vote
          raise Error::CustomError.new(nil, nil, "constituency_id is incorrect") unless [@user.assembly_constituency.id, @user.parliamentary_constituency.id].include?(@constituency_id)
          ## check if the candidature does not belong to users constituency
          raise Error::CustomError.new(400, "forbidden", "User ineligible to vote") unless @candidature.constituency.id == @user.assembly_constituency.id || @candidature.constituency.id == @user.parliamentary_constituency.id      
      end

      def validate_already_voted
        ## in other constituency
        raise Error::CustomError.new(400, "forbidden", "Already voted") if params.permit(:cancel_for)[:cancel_for].nil? && @user.candidate_votes.valid.find_by(election_id: @candidature.election.id) && @user.candidate_votes.valid.find_by(election_id: @candidature.election.id).candidature.constituency.id != @constituency_id
      end
    end
  end
end
