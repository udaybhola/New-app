module Leaderboard
  class Candidature
    include DeploymentTypeHelper
    include Leaderboard::CandidatureKeys
    include Leaderboard::CandidatureInsert
    include Leaderboard::CandidatureQuery
    include Leaderboard::CandidatureSeeds

    attr_reader :redis

    def initialize(redis = nil)
      @redis = redis
    end
  end
end
