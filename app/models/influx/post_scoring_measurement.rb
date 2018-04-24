module Influx
  class PostScoringMeasurement
    include Influx::Measurable

    def name
      'measurement_post_scoring'
    end

    def tags
      %w[score post_id state_id ac_id pc_id user_id]
    end

    def all_tags_query_string
      tags.map { |i| %("#{i}") }.join(", ")
    end

    def ingest_post_created(activity)
      return unless activity.activable
      post = activity.activable
      if post.region_type == 'Constituency'
        post_data = {
          values:    { score: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.country_state.id,
                       ac_id: post.region.is_assembly? ? post.region.id : 'none',
                       pc_id: post.region.is_parliament? ? post.region.id : 'none',
                       user_id: post.user ? post.user.id : 'none' },
          timestamp: post.created_at.to_i
        }
        db.client.write_point(name, post_data)
        Influx::EntityInstances.influencer_scoring_measurement.ingest_post_created(activity) if post.user
      elsif post.region_type == 'CountryState'
        post_data = {
          values:    { score: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.id,
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: 'none' },
          timestamp: post.created_at.to_i
        }
        db.client.write_point(name, post_data)
      elsif post.region_id.nil?
        # national level issue
        post_data = {
          values:    { score: 1 },
          tags:      { post_id: post.id,
                       state_id: 'none',
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: 'none' },
          timestamp: post.created_at.to_i
        }

        db.client.write_point(name, post_data)
      end
    end

    def delete_post_measurement_points(post_id)
      query = <<-eos
        delete from #{name} where post_id = '#{post_id}'
      eos

      data = db.client.query query
      ## influx returns empty if successful
      data.empty?
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

      return unless post
      if post.region_type == 'Constituency'
        post_data = {
          values:    { score: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.country_state.id,
                       user_id: post_activity.user ? post_activity.user.id : 'none' },
          timestamp: post_activity.created_at.to_i
        }

        if post.region.is_assembly?
          post_data[:tags][:ac_id] = post.region.id
          post_data[:tags][:pc_id] = post.region.parent.id
        elsif post.region.is_parliament?
          post_data[:tags][:pc_id] = post.region.id
          post_data[:tags][:ac_id] = 'none'
        end

        db.client.write_point(name, post_data)
      elsif post.region_type == 'CountryState'
        # state level issue
        post_data = {
          values:    { score: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.id,
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: post_activity.user ? post_activity.user.id : 'none' },
          timestamp: post_activity.created_at.to_i
        }
        db.client.write_point(name, post_data)

      elsif post.region_id.nil?
        # national level issue
        post_data = {
          values:    { score: 1 },
          tags:      { post_id: post.id,
                       state_id: 'none',
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: post_activity.user ? post_activity.user.id : 'none' },
          timestamp: post_activity.created_at.to_i
        }
        db.client.write_point(name, post_data)
      end

      Influx::EntityInstances.influencer_scoring_measurement.ingest_post_activity(activity)
    end

    def trending(options)
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      user_id = options[:user_id]
      topN = options[:top] || 25

      where_clause = ""
      if constituency_id
        constituency = Constituency.find(constituency_id)
        if constituency.is_assembly?
          where_clause = %( and "ac_id" = '#{constituency.id}')
        elsif constituency.is_parliament?
          where_clause = %( and "pc_id" = '#{constituency.id}')
        end
      elsif state_id
        where_clause = %( and "state_id" = '#{state_id}')
      else
        where_clause = %( and "ac_id" = 'none' and "pc_id" = 'none' and "state_id" = 'none')
      end
      query = <<-eos
        select top("score", "post_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where time >= now() - 520w and time <= now()
          #{where_clause}
          group by "post_id"
        )
      eos
      data = db.client.query query
      posts_ids = if data.empty?
                    []
                  else
                    data.first["values"].sort_by { |_i| - 1 * _i["score"] }
                        .map { |item| item["post_id"] }
                  end
      posts = Post.where(id: posts_ids).where.not(user_id: nil).to_a
      posts = posts.sort_by { |_post| posts_ids.index(_post.id) }
      no_of_issues, no_of_polls, arranged_data =
        ApiResponseModels::Api::V1::PostsData.fetch_from_active_record(user_id, posts, nil, nil, nil)
      data = ApiResponseModels::CustomOstruct.new
      data.offset = 0
      data.limit = 0
      data.no_of_issues = no_of_issues
      data.no_of_polls = no_of_polls
      data.posts = arranged_data
      data
    end
  end
end
