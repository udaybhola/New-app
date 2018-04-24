module Api
  module V1
    class ConstituenciesController < ApiV1Controller
      def top_parties
        idparams = params.permit(:id)
        raise Error::CustomError.new(nil, nil, "id must be present") if idparams.blank?
        constituency = Constituency.find(idparams["id"])
        raise Error::CustomError.new(nil, nil, "Constituency not found with id #{idparams['id']}") unless constituency
        @parties = if Rails.env.test?
                     ApiResponseModels::Api::V1::PartiesData.fetch_top_parties(constituency.id)
                   else
                     Leaderboards.candidatures.top_parties(constituency_id: constituency.id)
                   end
      end

      def parties_stats
        valid_params = params.permit(:id, :resolution, :party_ids)

        raise Error::CustomError.new(nil, nil, "id must be present") if valid_params.blank?
        constituency = Constituency.find(valid_params["id"])
        raise Error::CustomError.new(nil, nil, "Constituency not found with id #{valid_params['id']}") unless constituency

        resolution = valid_params["resolution"] || ''
        valid_resolutions = %w[last_24_hours last_week last_month since_the_beginning]
        raise Error::CustomError.new(nil, nil, "resolution param should be one of #{valid_resolutions}") unless valid_resolutions.include?(resolution)
        party_ids = valid_params["party_ids"] || ""
        party_ids = party_ids.split(",")
        raise Error::CustomError.new(nil, nil, "party_ids should be comma separated, seems like it is empty") if party_ids.empty?
        parties = Party.where(id: party_ids)
        raise Error::CustomError.new(nil, nil, "Some of the party id is not valid") unless party_ids.size == parties.count
        @stats = Influx::EntityInstances.candidature_scoring_measurement.parties_stats(
          resolution: resolution,
          party_ids: party_ids,
          constituency_id: constituency.id
        )
      end

      def latlng
        latlng = params.permit(:lat, :lng)
        lng = latlng["lng"].to_f || 0
        lat = latlng["lat"].to_f || 0
        raise Error::CustomError.new(nil, nil, "Must have a valid latitude and longitude") if lat <= 0 || lng <= 0

        query = "ST_Contains(shape, ST_GeometryFromText('POINT(? ?)', 4326))"
        @acs = Map.where(query, lng, lat).where("kind=?", "assembly")

        raise Error::CustomError.new(nil, nil, "Could not find a assemble constituency with given lat and lng") if @acs.empty?
        @cstate = @acs.first.mappable.country_state
        @hit_ac = @acs.first.mappable
      end

      def assembly
        constituency
      end

      def parliament
        constituency
      end

      def assembly_geojson
        geojson
      end

      def constituency_geojson
        const_geojson
      end

      def image
        constituency_id = params.permit(:id)["id"]
        raise Error::CustomError if constituency_id.blank?
        @constituency = Constituency.find(constituency_id)
        @image_obj = @constituency.image_obj
      end

      protected

      def constituency
        idparams = params.permit(:state_id)
        raise Error::CustomError.new(nil, nil, "State id must be present") if idparams.blank?
        @cstate = CountryState.find_by_id(idparams["state_id"])
        raise Error::CustomError.new(nil, nil, "State not present with id") if @cstate.nil?
      end

      def geojson
        idparams = params.permit(:state_id)
        raise Error::CustomError.new(nil, nil, "State id must be present") if idparams.blank?
        @cstate = CountryState.find_by_id(idparams["state_id"])
        results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Centroid(shape)) as wkt from maps where id='#{@cstate.map.id}'"
        if results&.first
          @center = RGeo::Cartesian.preferred_factory.parse_wkt(results.first['wkt'])
          @lon = @center.x
          @lat = @center.y
        end
        raise Error::CustomError.new(nil, nil, "State not present with id") if @cstate.nil?
      end

      def const_geojson
        idparams = params.permit(:constituency_id)
        raise Error::CustomError.new(nil, nil, "Constituency id must be present") if idparams.blank?
        @constituency = Constituency.find(idparams[:constituency_id])
        results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Centroid(shape)) as wkt from maps where id='#{@constituency.map.id}'"
        if results&.first
          @center = RGeo::Cartesian.preferred_factory.parse_wkt(results.first['wkt'])
          @lon = @center.x
          @lat = @center.y
        end
      end
    end
  end
end
