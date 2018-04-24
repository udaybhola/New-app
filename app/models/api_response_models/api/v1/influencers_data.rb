module ApiResponseModels
  module Api
    module V1
      class InfluencersData
        attr_accessor :influencer_id, :influencer_name, :influencer_profile_pic, :score, :rank, :constituency, :constituency_id, :has_cover_image, :cover_image

        def initialize(influencer_id, influencer_name, influencer_profile_pic, score, rank, constituency, constituency_id, has_cover_image, cover_image)
          @influencer_id = influencer_id
          @influencer_name = influencer_name
          @influencer_profile_pic = influencer_profile_pic
          @score = score
          @rank = rank
          @constituency = constituency
          @constituency_id = constituency_id
          @has_cover_image = has_cover_image
          @cover_image = cover_image
        end

        def self.fetch_from_active_record(constituency_id, query_param, offset, limit)
          constituency = Constituency.find(constituency_id)
          constituencies_arr = []
          constituencies_arr << if constituency.kind == "assembly"
                                  constituency_id
                                else
                                  constituency.children.map(&:id)
                                end

          valid_influencers = if query_param.nil?
                                User.where(constituency_id: constituencies_arr).joins(:profile).where("profiles.candidate_id is null")
                              else
                                User.joins(:profile).where(constituency_id: constituencies_arr).where("profiles.name LIKE ? and profiles.candidate_id is null ", "%#{query_param}%")
                              end
          influencers = []
          valid_influencers = valid_influencers.offset(offset).limit(limit)
          valid_influencers.each do |influencer|
            score = influencer.total_score
            ## TODO add rank
            influencers << new(influencer.id, influencer.profile.name, influencer.profile.profile_pic, score, influencer.rank, influencer.constituency.name, influencer.constituency.id, !influencer.profile.cover_photo_obj.nil?, influencer.profile.cover_photo_obj)
          end
          influencers
        end

        def self.fetch_data(constituency_id, sort_by = "scores_desc", query_param = nil, offset = 0, limit = 15)
          if Rails.env.test?
            influencers = fetch_from_active_record(constituency_id, query_param, offset, limit)
            case sort_by
            when "score_asc"
              influencers.sort_by(&:score)
            else
              influencers.sort_by(&:score).reverse
            end
          else
            if constituency_id.nil?
              data = Influx::Series.popular_influencers_nation(limit)
            else
              const = Constituency.find(constituency_id)
              data = []
              if const.is_assembly?
                data = Influx::Series.popular_influencers_ac(constituency_id, limit)
              elsif const.is_parliament?
                data = Influx::Series.popular_influencers_state(const.country_state.id, limit)
              end
            end
            return [] if data.empty?
            score_hash = data.first["values"].map { |item| [item["user_id"], item["total_score"]] }.to_h
            influencers = User.where(id: data.first["values"].map { |item| item["user_id"] }).where.not(constituency_id: nil)
            valid_influencers = []
            influencers.each do |influencer|
              score = score_hash[influencer.id]
              valid_influencers << new(influencer.id, influencer.profile.name, influencer.profile.profile_pic, score, 0, influencer.profile.user.constituency.name, influencer.constituency.id, !influencer.profile.cover_photo_obj.nil?, influencer.profile.cover_photo_obj)
            end
            valid_influencers.sort_by! { |_item| -_item.score }
          end
        end
      end
    end
  end
end
