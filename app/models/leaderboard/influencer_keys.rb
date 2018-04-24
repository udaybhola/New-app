module Leaderboard
  module InfluencerKeys
    extend ActiveSupport::Concern

    def national_key
      "#{prefix}-national"
    end

    def state_key(cs)
      "#{prefix}-state-#{cs.id}"
    end

    def constituency_key(cs, const)
      "#{prefix}-assembly-#{cs.id}-#{const.id}"
    end

    def prefix
      "#{deployment_type}-influencer"
    end
  end
end
