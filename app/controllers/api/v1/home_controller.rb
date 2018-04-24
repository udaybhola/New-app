module Api
  module V1
    class HomeController < ApiV1Controller
      before_action :validate_params, only: [:dashboard_data]

      def master_data; end

      def cloudinary_config
        render json: {
          data: {
            cloud_name: Cloudinary.config.cloud_name,
            api_key: Cloudinary.config.api_key,
            api_secret: Cloudinary.config.api_secret
          },
          status_code: 1
        }, status: :ok
      end

      def dashboard_data
        no_of_members_to_show = 15

        if @constituency&.is_assembly? && @state_id.blank?
          # assembly
          @influencers_data = if Rails.env.test?
                                ApiResponseModels::Api::V1::InfluencersData.fetch_data(@constituency_id)
                              else
                                Leaderboards.influencers.popular_influencers(constituency_id: @constituency_id, top: no_of_members_to_show)
                              end
          @top_parties = if Rails.env.test?
                           ApiResponseModels::Api::V1::PartiesData.fetch_top_parties(@constituency_id)
                         else
                           data = Leaderboards.parties.top_parties(constituency_id: @constituency_id)
                           data = nil if data.is_a?(Array) && data.empty?
                           data
                         end
          @top_parties_pc = if Rails.env.test?
                              ApiResponseModels::Api::V1::PartiesData.fetch_top_parties(@constituency_id)
                            else
                              data = Leaderboards.parties.top_parties(constituency_id: @constituency.parent.id)
                              data = nil if data.is_a?(Array) && data.empty?
                              data
                            end

          poll = @constituency.polls.dashboard.first
          @constituency_poll = format_poll(poll) if poll

        elsif @constituency&.is_assembly? && !@state_id.blank?
          # state
          @state = CountryState.find(@state_id)
          @dashboard_item_stats = DashboardItem.statistics_of_state(@state)
          @influencers_data = if Rails.env.test?
                                ApiResponseModels::Api::V1::InfluencersData.fetch_data(@constituency_id)
                              else
                                Leaderboards.influencers.popular_influencers(constituency_id: @constituency_id, state_id: @constituency.country_state.id, top: no_of_members_to_show)
                              end
          @top_parties_state_level = if Rails.env.test?
                                       ApiResponseModels::Api::V1::PartiesData.fetch_top_parties(nil, @constituency.country_state.id)
                                     else
                                       data = Leaderboards.parties.top_parties(state_id: @constituency.country_state.id)
                                       data = nil if data.is_a?(Array) && data.empty?
                                       data
                                     end
          poll = @constituency.country_state.admin_poll
          @state_poll = format_poll(poll) if poll
        else
          # national
          @dashboard_item_stats = DashboardItem.national_statistics
          @influencers_data = if Rails.env.test?
                                ApiResponseModels::Api::V1::InfluencersData.fetch_data(nil, nil, nil, 0, 15)
                              else
                                Leaderboards.influencers.popular_influencers(top: no_of_members_to_show)
                              end

          @top_parties_national_level = if Rails.env.test?
                                          ApiResponseModels::Api::V1::PartiesData.fetch_top_parties(nil, nil)
                                        else
                                          data = Leaderboards.parties.top_parties({})
                                          data = nil if data.is_a?(Array) && data.empty?
                                          data
                                        end

          nat_poll = Poll.national.dashboard.first
          @national_poll = format_poll(nat_poll) if nat_poll
        end

        @candidates_data = if Rails.env.test?
                             ApiResponseModels::Api::V1::CandidatesData.fetch_data(current_user_id, @constituency_id)
                           else
                             Leaderboards.candidatures.popular_candidatures(user_id: current_user_id,
                                                                            constituency_id: @constituency_id,
                                                                            state_id: @state_id)
                           end
      end

      private

      def validate_params
        @params = params.permit(:constituency_id, :state_id)
        @constituency_id = @params["constituency_id"]
        @constituency = Constituency.find(@constituency_id) if @constituency_id
        @state_id = @params["state_id"]
      end

      def format_poll(poll)
        formatted_poll = ApiResponseModels::CustomOstruct.new
        return formatted_poll if poll.nil?

        formatted_poll.id = poll.id
        formatted_poll.question = poll.question
        formatted_poll.poll_options = ApiResponseModels::Api::V1::PostsData.construct_poll_options(current_user_id, poll)
        formatted_poll
      end
    end
  end
end
