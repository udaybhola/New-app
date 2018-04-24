module ApiResponseModels
  module Api
    module V1
      class CandidatureListData
        attr_accessor :id, :year, :constituency, :election, :party, :result, :party_abbreviation

        def initialize(id, year, constituency, election, party, result, party_abbreviation)
          @id = id
          @year = year
          @constituency = constituency
          @election = election
          @party = party
          @result = result
          @party_abbreviation = party_abbreviation
        end

        def self.fetch_from_active_record(id)
          candidate = Candidate.find(id)
          candidatures = candidate.candidatures.order("created_at desc")
          candidature_list = []
          candidatures.each do |candidature|
            candidature_list << new(candidature.id, candidature.election.starts_at.year, candidature.constituency.name, candidature.election.kind, candidature.party.name, candidature.result, candidature.party.abbreviation)
          end
          candidature_list
        end

        def self.fetch_data(id)
          fetch_from_active_record(id)
        end
      end
    end
  end
end
