module Influx
  class InfluencerScoringMeasurement
    include Influx::Measurable

    def ingest_user_created(activity)
      user = activity.activable
      data = {
        values:    { score: 0 },
        tags:      { user_id: user.id },
        timestamp: user.created_at.to_i
      }
      if user.constituency
        if user.constituency.is_assembly?
          data[:tags][:ac_id] = user.constituency.id
          data[:tags][:pc_id] = user.constituency.parent.id
          data[:tags][:state_id] = user.constituency.country_state.id
        elsif user.constituency.is_parliament?
          data[:tags][:ac_id] = 'none'
          data[:tags][:pc_id] = user.constituency.id
          data[:tags][:state_id] = user.constituency.country_state.id
        else
          data[:tags][:ac_id] = 'none'
          data[:tags][:pc_id] = 'none'
          data[:tags][:state_id] = 'none'
        end
      end
      db.client.write_point(name, data)
    end

    def ingest_candidature_voted(activity)
      candidate_vote = activity.activable
      data = {
        values:    { score: activity.score },
        tags:      { state_id: candidate_vote.candidature.constituency.country_state.id,
                     election_id: candidate_vote.candidature.election.id,
                     party_id: candidate_vote.candidature.party.id,
                     user_id: candidate_vote.user_id },
        timestamp: candidate_vote.created_at.to_i
      }

      if candidate_vote.candidature.constituency.is_assembly?
        data[:tags][:ac_id] = candidate_vote.candidature.constituency.id
        data[:tags][:pc_id] = candidate_vote.candidature.constituency.parent.id
      elsif candidate_vote.candidature.constituency.is_parliament?
        data[:tags][:pc_id] = candidate_vote.candidature.constituency.id
        data[:tags][:ac_id] = 'none'
      else
        data[:tags][:pc_id] = 'none'
        data[:tags][:ac_id] = 'none'
      end

      db.client.write_point(name, data)
    end

    def ingest_post_created(activity)
      post = activity.activable
      score = activity.score
      data = {
        values:    { score: score },
        tags:      { state_id: post.region.country_state.id,
                     user_id: post.user.id },
        timestamp: post.created_at.to_i
      }

      if post.region.is_assembly?
        data[:tags][:ac_id] = post.region.id
        data[:tags][:pc_id] = post.region.parent.id
      elsif post.region.is_parliament?
        data[:tags][:pc_id] = post.region.id
        data[:tags][:ac_id] = 'none'
      end
      db.client.write_point(name, data)
    end

    def ingest_post_activity(activity)
      post_activity = activity.activable
      post =
        case post_activity.class.name
        when 'Comment'
          post_activity.post
        when 'Like'
          if post_activity.likeable.class.name == 'Comment'
            post_activity.likeable.post
          else
            post_activity.likeable
          end
        when 'PollVote'
          post_activity.poll
        end

      data = {
        values:    { score: activity.score },
        tags:      { user_id: post_activity.user.id },
        timestamp: post_activity.created_at.to_i
      }

      if post.region_type == 'Constituency'
        data[:tags][:state_id] = post.region.country_state.id
        if post.region.is_assembly?
          data[:tags][:ac_id] = post.region.id
          data[:tags][:pc_id] = post.region.parent.id
        elsif post.region.is_parliament?
          data[:tags][:pc_id] = post.region.id
          data[:tags][:ac_id] = 'none'
        end
      elsif post.region_type == 'CountryState'
        data[:tags][:state_id] = post.region.id
        data[:tags][:pc_id] = 'none'
        data[:tags][:ac_id] = 'none'
      elsif post.region_id.nil?
        data[:tags][:state_id] = 'none'
        data[:tags][:pc_id] = 'none'
        data[:tags][:ac_id] = 'none'
      end
      db.client.write_point(name, data)
    end

    def name
      'measurement_influencer_scoring'
    end

    def tags
      %w[score user_id state_id pc_id ac_id election_id party_id]
    end

    def popular_influencers(options = {})
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      data = []
      if constituency_id.blank? && state_id.blank?
        data = popular_influencers_nation(options)
      else
        const = Constituency.find(constituency_id)
        if const.is_assembly? && state_id.blank?
          data = popular_influencers_ac(options.merge(ac_id: const.id))
        elsif const.is_assembly? && !state_id.blank?
          data = popular_influencers_state(options.merge(state_id: state_id))
        elsif const.is_parliament? && state_id.blank?
          # we dont have parliament level influencers
          data = []
        end
      end
      data
    end

    def popular_influencers_ac(options)
      return [] if options[:ac_id].blank?
      ac_id = options[:ac_id]
      topN = options[:top] || 100

      query = <<-eos
        select top("score", "user_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = '#{ac_id}'
          and
          time >= now() - 520w and time <= now()
          group by "user_id"
        )
      eos
      data = db.client.query query
      build_top_influencers_response_from_data(data)
    end

    def popular_influencers_state(options)
      return [] if options[:state_id].blank?
      state_id = options[:state_id]
      topN = options[:top] || 100

      query = <<-eos
        select top("score", "user_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "state_id" = '#{state_id}'
          and
          time >= now() - 520w and time <= now()
          group by "user_id"
        )
      eos
      data = db.client.query query
      build_top_influencers_response_from_data(data)
    end

    def popular_influencers_nation(options)
      topN = options[:top] || 100

      query = <<-eos
        select top("score", "user_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where time >= now() - 520w and time <= now()
          group by "user_id"
        )
      eos
      data = db.client.query query
      build_top_influencers_response_from_data(data)
    end

    def user_scores
      query = <<-eos
        select sum("score") as "score"
        from #{autogen_db}
        where time >= now() - 1d and time <= now()
        group by "user_id"
      eos
      db.client.query query
    end

    def all_tags_query_string
      tags.map { |i| %("#{i}") }.join(", ")
    end

    def build_top_influencers_response_from_data(data)
      return [] if data.empty?
      influencers = User.where(id: data.first["values"].map { |item| item["user_id"] })
                        .where.not(constituency_id: nil)

      valid_influencers = []
      influencers.each do |influencer|
        score = influencer.total_score
        valid_influencers << ApiResponseModels::Api::V1::InfluencersData.new(
          influencer.id, influencer.profile.name,
          influencer.profile.profile_pic, score, 0,
          influencer.constituency.name,
          influencer.constituency.id,
          !influencer.profile.cover_photo_obj.nil?
        )
      end
      valid_influencers.sort_by! { |_item| -_item.score }
    end
  end
end
