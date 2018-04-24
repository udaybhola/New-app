module Leaderboard
  module InfluencerInsert
    extend ActiveSupport::Concern

    def register_influencer_score(influencer)
      if influencer&.constituency
        key = national_key
        redis.zadd key, influencer.total_score, influencer.id

        key = state_key(influencer.constituency.country_state)
        redis.zadd key, influencer.total_score, influencer.id

        key = constituency_key(influencer.constituency.country_state, influencer.constituency)
        redis.zadd key, influencer.total_score, influencer.id
      end
    end

    def reset_influencer_scores(influencer_ids)
      unless influencer_ids.empty?
        influencer_scores_tuple = influencer_scores(influencer_ids)
        key = national_key
        redis.zadd key, influencer_scores_tuple

        influencer_ids.each do |influencer_id|
          influencer = User.where(id: influencer_id).first
          
          next if influencer.nil?

          key = state_key(influencer.constituency.country_state)
          redis.zadd key, influencer.total_score, influencer.id

          key = constituency_key(influencer.constituency.country_state, influencer.constituency)
          redis.zadd key, influencer.total_score, influencer.id
        end
      end
    end

    def drop_influencer(influencer_id)
      influencer = User.unscoped.find(influencer_id)
      if influencer&.constituency
        key = constituency_key(influencer.constituency.country_state, influencer.constituency)
        redis.zrem key, influencer.id
      end
    end

    def rank(influencer_id)
      key = national_key
      redis.zrank key, influencer_id
    end

    private

    def influencer_scores(influencer_ids)
      influencer_array = []
      influencer_ids.each do |id|
        influencer_array << [User.find(id).total_score, id] unless User.where(id: id).empty?
      end
      influencer_array
    end
  end
end
