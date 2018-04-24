module Leaderboard
  module InfluencerQuery
    extend ActiveSupport::Concern

    include Leaderboard::InfluencerResponseBuilder

    def popular_influencers(options = {})
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      return popular_influencers_nation(options) if constituency_id.blank? && state_id.blank?
      return popular_influencers_state(options) unless state_id.blank?
      popular_influencers_const(options)
    end

    def popular_influencers_nation(options = {})
      top = options[:top] || 15
      key = national_key
      elems = redis.zrevrange key, 0, top, with_scores: true
      build_top_influencers_from_redis_key(elems.to_h)
    end

    def popular_influencers_state(options = {})
      top = options[:top] || 15
      country_state = CountryState.find(options[:state_id])
      return [] if country_state.blank?

      key = state_key(country_state)
      elems = redis.zrevrange key, 0, top, with_scores: true
      build_top_influencers_from_redis_key(elems.to_h)
    end

    def popular_influencers_const(options = {})
      top = options[:top] || 15
      const = Constituency.find(options[:constituency_id])
      return [] if const.blank?

      key = constituency_key(const.country_state, const)
      elems = redis.zrevrange key, 0, top, with_scores: true
      build_top_influencers_from_redis_key(elems.to_h)
    end
  end
end
