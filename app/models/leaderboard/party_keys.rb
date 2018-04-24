module Leaderboard
  module PartyKeys
    extend ActiveSupport::Concern

    def votes_parliament_key(election)
      "#{prefix}-votes-parliament-#{election.id}"
    end

    def votes_assembly_key(cs, election)
      "#{prefix}-votes-assembly-#{cs.id}-#{election.id}"
    end

    def votes_constituency_assembly_key(cs, const, election)
      "#{prefix}-votes-assembly-#{cs.id}-#{const.id}-#{election.id}"
    end

    def votes_constituency_parliament_key(cs, const, election)
      "#{prefix}-votes-parliament-#{cs.id}-#{const.id}-#{election.id}"
    end

    def seats_assembly_key(cs, election)
      "#{prefix}-seats-assembly-#{cs.id}-#{election.id}"
    end

    def seats_parliament_key(election)
      "#{prefix}-seats-parliament-#{election.id}"
    end

    def seats_constituency_assembly_key(cs, const, election)
      "#{prefix}-seats-assembly-#{cs.id}-#{const.id}-#{election.id}"
    end

    def seats_constituency_parliament_key(cs, const, election)
      "#{prefix}-seats-parliament-#{cs.id}-#{const.id}-#{election.id}"
    end

    def prefix
      "#{deployment_type}-party"
    end
  end
end
