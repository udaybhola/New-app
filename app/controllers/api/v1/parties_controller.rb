module Api
  module V1
    class PartiesController < ApiV1Controller
      before_action :validate_join_request, only: :join
      before_action :validate_top_request, only: :top

      def index
        @parties = ApiResponseModels::Api::V1::PartiesData.fetch_data
      end

      def show
        @party = ApiResponseModels::Api::V1::PartyProfileData.fetch_data(params.permit(:id)["id"], @user)
      end

      def party_leaders
        party = Party.find(params.permit(:id)["id"])
        @party_leaders = ApiResponseModels::Api::V1::PartyLeadersData.fetch_data(party)
      end

      def manifesto
        @manifesto = Party.find(params.permit(:id)["id"]).manifesto
        unless @manifesto.file.nil?
          result = Cloudinary::Api.resource(@manifesto.file.public_id.to_s, pages: true)
          @pages = result["pages"]
        end
      end

      def join
        party = Party.find(@params["id"])
        party_membership = PartyMembership.where(user: @user, party: party, is_valid: true, constituency_id: @constituency_id).first
        if party_membership&.is_valid
          render json: {
            status: 200,
            message: "already joined"
          }
        else
          description = params.permit(:description)["description"]
          @party_membership = PartyMembership.new(party: party, user: @user, is_valid: false, constituency_id: @constituency_id, description: description)
          unless @party_membership.save
            render json: {
              error: "internal_server_error",
              message: @party_membership.errors.messages,
              status: 500
            } && return
          end

          render json: {
            status: 200,
            message: "submitted requested for joining"
          }
        end
      end

      private

      def validate_join_request
        @params = params.permit(:constituency_id, :description, :id)

        @constituency_id = @params["constituency_id"]
        raise Error::CustomError unless [@user.assembly_constituency.id, @user.parliamentary_constituency].include?(@constituency_id)
      end

      def validate_top_request
        @params = params.permit(:constituency_id, :state_id)

        @constituency_id = @params["constituency_id"]
        @state_id = @params["state_id"]
      end
    end
  end
end
