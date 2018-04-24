module Leaderboard
  module InfluencerResponseBuilder
    extend ActiveSupport::Concern

    def build_top_influencers_from_redis_key(data)
      influencers = User.where(id: data.keys)

      valid_influencers = []
      influencers.each do |influencer|
        score = data[influencer.id]
        valid_influencers << ApiResponseModels::Api::V1::InfluencersData.new(
          influencer.id, influencer.profile.name,
          influencer.profile.profile_pic, score, 0,
          influencer.constituency.name,
          influencer.constituency.id,
          !influencer.profile.cover_photo_obj.nil?,
          influencer.profile.cover_photo_obj
        )
      end
      valid_influencers.sort_by! { |item| -item.score }
    end
  end
end
