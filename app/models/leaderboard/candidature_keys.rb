module Leaderboard
  module CandidatureKeys
    extend ActiveSupport::Concern

    def parliament_key(election)
      "#{prefix}-parliament-#{election.id}"
    end

    def assembly_key(cs, election)
      "#{prefix}-assembly-#{cs.id}-#{election.id}"
    end

    def constituency_assembly_key(cs, const, election)
      "#{prefix}-assembly-#{cs.id}-#{const.id}-#{election.id}"
    end

    def constituency_parliament_key(cs, const, election)
      "#{prefix}-parliament-#{cs.id}-#{const.id}-#{election.id}"
    end

    def prefix
      "#{deployment_type}-candidatures"
    end
  end
end
