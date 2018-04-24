module Api
  module V1
    class CandidateNominationsController < ApiV1Controller
      def create
        candidate_nomination = CandidateNomination.new(candidate_nomination_params)
        if candidate_nomination.save
          render json: { data: {}, status_code: 1 }
        else
          raise Error::CustomError.new(nil, nil, "Validations failed")
        end
      end

      def candidate_nomination_params
        params.require(:candidate_nomination)
              .permit(:name, :age,
                      :party_id, :election_kind,
                      :country_state_id, :parliament_id,
                      :assembly_id, news_pr_links: [])
      end
    end
  end
end
