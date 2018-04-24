module Api
  module V1
    class CountryStatesController < ApiV1Controller
      before_action :validate_top_parties_request, only: [:geojson, :top_parties, :geojson_parliamentary, :parties_stats, :top_parties_constituency_wise]

      def top_parties
        @content = if Rails.env.test?
                     ApiResponseModels::Api::V1::PartiesData.fetch_top_parties(nil, @id)
                   else
                     Leaderboards.candidatures.top_parties(state_id: @id)
                   end
      end

      def top_parties_constituency_wise
        @content = Influx::EntityInstances.candidature_scoring_measurement
                                          .top_parties_constituency_wise(state_id: @id)
      end

      def parties_stats
        valid_params = params.permit(:resolution, :party_ids)

        resolution = valid_params["resolution"] || ''
        valid_resolutions = %w[last_24_hours last_week last_month since_the_beginning]
        raise Error::CustomError.new(nil, nil, "resolution param should be one of #{valid_resolutions}") unless valid_resolutions.include?(resolution)
        party_ids = valid_params["party_ids"] || ""
        party_ids = party_ids.split(",")
        raise Error::CustomError.new(nil, nil, "party_ids should be comma separated, seems like it is empty") if party_ids.empty?
        parties = Party.where(id: party_ids)
        raise Error::CustomError.new(nil, nil, "Some of the party id is not valid") unless party_ids.size == parties.count

        @stats = Influx::EntityInstances.candidature_scoring_measurement.parties_stats(
          state_id: @id,
          resolution: resolution,
          party_ids: party_ids
        )
      end

      def popular_candidatures
        @candidates = if Rails.env.test?
                        ApiResponseModels::Api::V1::CandidatesData.fetch_data(current_user_id, nil, nil, nil)
                      else
                        Influx::EntityInstances.candidature_scoring_measurement.popular_candidatures(user_id: current_user_id)
                      end
      end

      def popular_influencers
        @influencers = if Rails.env.test?
                         ApiResponseModels::Api::V1::InfluencersData.fetch_data(nil, nil, nil, 0, 15)
                       else
                         Leaderboards.influencers.popular_influencers({})
                       end
      end

      def geojson_parliamentary
        @consts = Constituency.where(kind: 'parliamentary')
      end

      def geojson
        raise Error::CustomError.new(nil, nil, "State id should be present") if @id.blank?
        @cstate = CountryState.find(@id)
        raise Error::CustomError.new(nil, nil, "State not present with id") if @cstate.nil?
        results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Centroid(shape)) as wkt from maps where id='#{@cstate.map.id}'"
        if results&.first
          @center = RGeo::Cartesian.preferred_factory.parse_wkt(results.first['wkt'])
          @lon = @center.x
          @lat = @center.y
        end
      end

      private

      def validate_top_parties_request
        @params = params.permit(:id)
        @id = @params["id"]
      end
    end
  end
end
