module Leaderboard
  class Influencer
    include DeploymentTypeHelper
    include Leaderboard::InfluencerKeys
    include Leaderboard::InfluencerInsert
    include Leaderboard::InfluencerQuery
    include Leaderboard::InfluencerSeeds

    attr_reader :redis

    def initialize(redis = nil)
      @redis = redis
    end
  end
end
