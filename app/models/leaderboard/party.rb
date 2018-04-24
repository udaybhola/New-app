module Leaderboard
  class Party
    include DeploymentTypeHelper
    include Leaderboard::PartyKeys
    include Leaderboard::PartyInsert
    include Leaderboard::PartyQuery
    include Leaderboard::PartySeeds

    attr_reader :redis

    def initialize(redis = nil)
      @redis = redis
    end
  end
end
