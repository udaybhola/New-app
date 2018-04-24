# Measurement: Candidate Popularity, fields=total_vote_count,tags=state_id,election_id,constituency_id,candidature_id,party_id
# Measurement: Influencer Popularity, fields=total_score,tags=state_id,ac_id,pc_id,user_id
# Measurement: Trending Posts, fields=tick,tags=post_id,state_id,ac_id,pc_id
# Measurement: Poll Voting, fields=tick,tags=poll_id,poll_vote_id
module Influx
  class Series
    def self.ingest_candidature_created(candidature)
      total_votes = CandidateVote.valid.where(candidature_id: candidature.id).count
      data = {
        values:    { total_vote_count: total_votes },
        tags:      { state_id: candidature.constituency.country_state.id,
                     candidature_id: candidature.id,
                     election_id: candidature.election_id,
                     party_id: candidature.party.id },
        timestamp: Time.now.to_i
      }
      if candidature.constituency.is_assembly?
        data[:tags][:ac_id] = candidature.constituency.id
        data[:tags][:pc_id] = candidature.constituency.parent.id
      elsif candidature.constituency.is_parliament?
        data[:tags][:ac_id] = 'none'
        data[:tags][:pc_id] = candidature.constituency.id
      end
      Influx::Config::DB_REGULAR.write_point(Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY, data)
    end

    def self.ingest_user_created(user)
      user_data = {
        values:    { total_score: 0 },
        tags:      { user_id: user.id },
        timestamp: Time.now.to_i
      }
      if user.constituency
        if user.constituency.is_assembly?
          user_data[:tags][:ac_id] = user.constituency.id
          user_data[:tags][:pc_id] = user.constituency.parent.id
          user_data[:tags][:state_id] = user.constituency.country_state.id
        elsif user.constituency.is_parliament?
          user_data[:tags][:ac_id] = 'none'
          user_data[:tags][:pc_id] = user.constituency.id
          user_data[:tags][:state_id] = user.constituency.country_state.id
        end
      end
      Influx::Config::DB_REGULAR.write_point(Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY, user_data)
    end

    def self.ingest_post_created(post)
      if post.region_type == 'Constituency'
        post_data = {
          values:    { tick: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.country_state.id,
                       ac_id: post.region.is_assembly? ? post.region.id : 'none',
                       pc_id: post.region.is_parliament? ? post.region.id : 'none',
                       user_id: post.user ? post.user.id : 'none' },
          timestamp: Time.now.to_i
        }
        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POST_TRENDING, post_data)
        if post.user
          total_score = Activity.where(user_id: post.user.id).sum(:score)
          user_data = {
            values:    { total_score: total_score },
            tags:      { state_id: post.region.country_state.id,
                         user_id: post.user.id },
            timestamp: Time.now.to_i
          }

          if post.region.is_assembly?
            user_data[:tags][:ac_id] = post.region.id
            user_data[:tags][:pc_id] = post.region.parent.id
          elsif post.region.is_parliament?
            user_data[:tags][:pc_id] = post.region.id
            user_data[:tags][:ac_id] = 'none'
          end
          Influx::Config::DB_REGULAR.write_point(Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY, user_data)
        end
      elsif post.region_type == 'CountryState'
        # state level issue
        post_data = {
          values:    { tick: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.id,
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: 'none' },
          timestamp: Time.now.to_i
        }
        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POST_TRENDING, post_data)
      elsif post.region_id.nil?
        # national level issue
        post_data = {
          values:    { tick: 1 },
          tags:      { post_id: post.id,
                       state_id: 'none',
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: 'none' },
          timestamp: Time.now.to_i
        }
        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POST_TRENDING, post_data)
      end
    end

    def self.ingest_post_activity(post_activity)
      post =
        case post_activity.class.name
        when 'Comment'
          post_activity.post
        when 'Like'
          post_activity.likeable
        when 'PollVote'
          post_activity.poll
        end
      if post.region_type == 'Constituency'
        post_data = {
          values:    { tick: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.country_state.id,
                       user_id: post_activity.user ? post_activity.user.id : 'none' },
          timestamp: Time.now.to_i
        }

        if post.region.is_assembly?
          post_data[:tags][:ac_id] = post.region.id
          post_data[:tags][:pc_id] = post.region.parent.id
        elsif post.region.is_parliament?
          post_data[:tags][:pc_id] = post.region.id
          post_data[:tags][:ac_id] = 'none'
        end

        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POST_TRENDING, post_data)
        if post_activity.user
          total_score = Activity.where(user_id: post_activity.user.id).sum(:score)
          user_data = {
            values:    { total_score: total_score },
            tags:      { state_id: post.region.country_state.id,
                         user_id: post_activity.user.id },
            timestamp: Time.now.to_i
          }

          if post.region.is_assembly?
            user_data[:tags][:ac_id] = post.region.id
            user_data[:tags][:pc_id] = post.region.parent.id
          elsif post.region.is_parliament?
            user_data[:tags][:pc_id] = post.region.id
            user_data[:tags][:ac_id] = 'none'
          end
        end
        Influx::Config::DB_REGULAR.write_point(Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY, user_data)
      elsif post.region_type == 'CountryState'
        # state level issue
        post_data = {
          values:    { tick: 1 },
          tags:      { post_id: post.id,
                       state_id: post.region.id,
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: 'none' },
          timestamp: Time.now.to_i
        }
        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POST_TRENDING, post_data)
      elsif post.region_id.nil?
        # national level issue
        post_data = {
          values:    { tick: 1 },
          tags:      { post_id: post.id,
                       state_id: 'none',
                       ac_id: 'none',
                       pc_id: 'none',
                       user_id: 'none' },
          timestamp: Time.now.to_i
        }
        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POST_TRENDING, post_data)
      end
    end

    def self.ingest_candidate_voted(candidate_vote)
      is_new_vote = candidate_vote.previous_votes.empty?
      total_votes = CandidateVote.valid.where(candidature_id: candidate_vote.candidature_id).count
      data = {
        values:    { total_vote_count: total_votes },
        tags:      { state_id: candidate_vote.candidature.constituency.country_state.id,
                     candidature_id: candidate_vote.candidature.id,
                     election_id: candidate_vote.candidature.election_id,
                     party_id: candidate_vote.candidature.party.id },
        timestamp: Time.now.to_i
      }
      if candidate_vote.candidature.constituency.is_assembly?
        data[:tags][:ac_id] = candidate_vote.candidature.constituency.id
        data[:tags][:pc_id] = candidate_vote.candidature.constituency.parent.id
      elsif candidate_vote.candidature.constituency.is_parliament?
        data[:tags][:ac_id] = 'none'
        data[:tags][:pc_id] = candidate_vote.candidature.constituency.id
      end
      if is_new_vote
        Influx::Config::DB_REGULAR.write_point(Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY, data)
      else
        previous_vote = candidate_vote.previous_votes.first
        prev_total_votes = CandidateVote.valid.where(candidature_id: previous_vote.candidature_id).count
        data[:series] = Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY
        prev_data = {
          series: Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY,
          values:    { total_vote_count: prev_total_votes },
          tags:      { state_id: previous_vote.candidature.constituency.country_state.id,
                       candidature_id: previous_vote.candidature.id,
                       election_id: previous_vote.candidature.election_id,
                       party_id: previous_vote.candidature.party.id },
          timestamp: Time.now.to_i
        }
        if previous_vote.candidature.constituency.is_assembly?
          prev_data[:tags][:ac_id] = previous_vote.candidature.constituency.id
          prev_data[:tags][:pc_id] = previous_vote.candidature.constituency.parent.id
        elsif previous_vote.candidature.constituency.is_parliament?
          prev_data[:tags][:ac_id] = 'none'
          prev_data[:tags][:pc_id] = previous_vote.candidature.constituency.id
        end
        precision = 's'
        content = []
        content << data
        content << prev_data
        Influx::Config::DB_REGULAR.write_points(content, precision)
      end

      ## When voting happens, influencer popularity changes
      total_score = Activity.where(user_id: candidate_vote.user_id).sum(:score)
      user_data = {
        values:    { total_score: total_score },
        tags:      { state_id: candidate_vote.candidature.constituency.country_state.id,
                     user_id: candidate_vote.user_id },
        timestamp: Time.now.to_i
      }

      if candidate_vote.candidature.constituency.is_assembly?
        user_data[:tags][:ac_id] = candidate_vote.candidature.constituency.id
        user_data[:tags][:pc_id] = candidate_vote.candidature.constituency.parent.id
      elsif candidate_vote.candidature.constituency.is_parliament?
        user_data[:tags][:pc_id] = candidate_vote.candidature.constituency.id
        user_data[:tags][:ac_id] = 'none'
      end

      Influx::Config::DB_REGULAR.write_point(Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY, user_data)
    end

    def self.ingest_poll_voted(poll_vote)
      previous_votes = poll_vote.previous_votes
      if previous_votes.empty?
        data = {
          values:    { tick: 1 },
          tags:      { poll_id: poll_vote.poll_id,
                       poll_option_id: poll_vote.poll_option_id },
          timestamp: Time.now.to_i
        }
        Influx::Config::DB_TRENDING.write_point(Influx::Config::MEASUREMENT_POLL_VOTING_TRENDING, data)
      else
        prev_vote = poll_vote.previous_votes.first
        data_one = {
          series: Influx::Config::MEASUREMENT_POLL_VOTING_TRENDING,
          values:    { tick: 1 },
          tags:      { poll_id: poll_vote.poll_id,
                       poll_option_id: poll_vote.poll_option_id },
          timestamp: Time.now.to_i
        }
        data_two = {
          series: Influx::Config::MEASUREMENT_POLL_VOTING_TRENDING,
          values:    { tick: -1 },
          tags:      { poll_id: prev_vote.poll_id,
                       poll_option_id: prev_vote.poll_option_id },
          timestamp: Time.now.to_i
        }
        content = []
        content << data_one
        content << data_two
        Influx::Config::DB_REGULAR.write_points(content, 's')
      end
    end

    def self.ingest(activity)
      case activity.activable_type
      when 'Candidature'
        candidature = activity.activable
        ingest_candidature_created(candidature)
      when 'User'
        user = activity.user
        ingest_user_created(user)
      when 'CandidateVote'
        candidate_vote = activity.activable
        ingest_candidate_voted(candidate_vote)
      when 'Post'
        post = activity.activable
        ingest_post_created(post)
      when 'Comment'
        comment = activity.activable
        ingest_post_activity(comment)
      when 'Like'
        like = activity.activable
        ingest_post_activity(like)
      when 'PollVote'
        poll_vote = activity.activable
        ingest_post_activity(poll_vote)
        ingest_poll_voted(poll_vote)
      end
    end

    def self.popular_candidatures_ac(election_id = '', ac_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_vote_count") as "total_votes"}
      sub_query_columns = %("candidature_id", "party_id", "ac_id", "election_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}")

      sub_query_group_by = %{"candidature_id", time(1d) fill(previous)}
      where_election_clause = %("election_id" = '#{election_id}')
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = ac_id.blank? ? %(where #{where_election_clause} and #{where_time_clause}) : %(where "ac_id" = '#{ac_id}' and #{where_election_clause} and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_votes", "candidature_id", "party_id", "ac_id", "election_id", "state_id", #{_page_size}) as "vote_count"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_candidatures_pc(election_id = '', pc_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_vote_count") as "total_votes"}
      sub_query_columns = %("candidature_id", "party_id", "pc_id", "election_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}")

      sub_query_group_by = %{"candidature_id", time(1d) fill(previous)}
      where_election_clause = %("election_id" = '#{election_id}')
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = pc_id.blank? ? %(where #{where_election_clause} and #{where_time_clause}) : %(where "pc_id" = '#{pc_id}' and "ac_id" = 'none' and #{where_election_clause} and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_votes", "candidature_id", "party_id", "pc_id", "election_id", "state_id", #{_page_size}) as "vote_count"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_candidatures_state(election_id = '', state_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_vote_count") as "total_votes"}
      sub_query_columns = %("candidature_id", "party_id", "ac_id", "pc_id", "election_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}")

      sub_query_group_by = %{"candidature_id", time(1d) fill(previous)}
      where_election_clause = %("election_id" = '#{election_id}' and "ac_id" <> 'none')
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = state_id.blank? ? %(where #{where_election_clause} and #{where_time_clause}) : %(where "state_id" = '#{state_id}' and #{where_election_clause} and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_votes", "candidature_id", "party_id", "ac_id", "pc_id", "election_id", "state_id", #{_page_size}) as "vote_count"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_candidatures_nation(election_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_vote_count") as "total_votes"}
      sub_query_columns = %("candidature_id", "party_id", "ac_id", "pc_id", "election_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}")

      sub_query_group_by = %{"candidature_id", time(1d) fill(previous)}
      where_election_clause = %("election_id" = '#{election_id}' and "ac_id" = 'none')
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = %(where #{where_election_clause} and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_votes", "candidature_id", "party_id", "ac_id", "pc_id", "election_id", "state_id", #{_page_size}) as "vote_count"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_influencers_ac(constituency_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_score") as "total_score"}
      sub_query_columns = %("user_id", "ac_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY}")

      sub_query_group_by = %{"user_id", time(1d) fill(previous)}
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = constituency_id.blank? ? %(where #{where_time_clause}) : %(where "ac_id" = '#{constituency_id}' and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_score", "user_id", "ac_id", "state_id", #{_page_size}) as "total_score"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_influencers_pc(constituency_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_score") as "total_score"}
      sub_query_columns = %("user_id", "pc_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY}")

      sub_query_group_by = %{"user_id", time(1d) fill(previous)}
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = constituency_id.blank? ? %(where #{where_time_clause}) : %(where "pc_id" = '#{constituency_id}' and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_score", "user_id", "pc_id", "state_id", #{_page_size}) as "total_score"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_influencers_state(state_id = '', _page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_score") as "total_score"}
      sub_query_columns = %("user_id", "state_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY}")

      sub_query_group_by = %{"user_id", time(1d) fill(previous)}
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = state_id.blank? ? %(where #{where_time_clause}) : %(where "state_id" = '#{state_id}' and #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_score", "user_id", "state_id", #{_page_size}) as "total_score"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.popular_influencers_nation(_page_size = 15, _page_number = 0)
      sub_query_func = %{last("total_score") as "total_score"}
      sub_query_columns = %("user_id")
      table_name = %("#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_INFLUENCER_POPULARITY}")

      sub_query_group_by = %{"user_id", time(1d) fill(previous)}
      where_time_clause = %{time >= now() - 30d and time <= now()}
      where_clause = %(where #{where_time_clause})
      sub_query = %(select #{sub_query_func}, #{sub_query_columns} from #{table_name} #{where_clause} group by #{sub_query_group_by} )

      query_top = %{top("total_score", "user_id", #{_page_size}) as "total_score"}
      query_string = %{select #{query_top} from (#{sub_query})}
      Influx::Config::DB_REGULAR.query query_string
    end

    def self.trending_posts_constituency(constituency_id = '', _page_size = 15, _page_number = 0)
      trending_posts(constituency_id, nil)
    end

    def self.trending_posts_state(state_id = '', _page_size = 15, _page_number = 0)
      trending_posts(nil, state_id)
    end

    def self.trending_posts_nation(_page_size = 15, _page_number = 0)
      trending_posts(nil, nil)
    end

    def self.trending_posts(constituency_id = nil, state_id = nil)
      where_clause = ""
      if constituency_id
        constituency = Constituency.find(constituency_id)
        if constituency.is_assembly?
          where_clause = %( and "ac_id" = '#{constituency.id}')
        elsif constituency.is_parliament?
          where_clause = %( and "pc_id" = '#{constituency.id}')
        end
      elsif state_id
        # state level
        where_clause = %( and "state_id" = '#{state_id}')
      else
        where_clause = %( and "ac_id" = 'none' and "pc_id" = 'none' and "state_id" = 'none')
      end
      query = <<-eos
        select top("rank", "post_id", 50)
        from (select last("sum") as "rank" from
        (select sum(tick) as "sum" from
        "#{Influx::Config::NAME_DB_TRENDING}"."autogen"."#{Influx::Config::MEASUREMENT_POST_TRENDING}"
        where time >= now() - 30d and time <= now() #{where_clause}
        group by time(1d), "post_id" fill(previous))
        group by "post_id")
      eos
      data = Influx::Config::DB_TRENDING.query query
    end

    def self.top_parties_of_constituency_ac(election_id = nil, ac_id = nil)
      content = []
      unless ac_id.blank?
        query = <<-eos
            select sum("vote_count") as "total_vote_count" from (
                select last("total_vote_count") as "vote_count",
                "candidature_id", "party_id", "ac_id", "election_id", "state_id" from
                "#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}"
                where "ac_id" = '#{ac_id}'
                and "election_id" = '#{election_id}'
                and time >= now() - 30d and time <= now()
                group by "candidature_id", time(1d) fill(previous)
              ) group by "party_id"
            eos
        data = Influx::Config::DB_REGULAR.query query
        items = data.map do |point|
          {
            party_id: point["tags"]["party_id"],
            total_vote_count: point["values"].first["total_vote_count"].to_i
          }
        end
        items.select! { |item| item[:total_vote_count] > 0 }
        items.sort_by! { |item| -1 * item[:total_vote_count] }
        party_ids = items.map { |item| item[:party_id] }
        parties = Party.where(id: party_ids)
        party_count_hash = items.map { |item| [item[:party_id], item[:total_vote_count]] }.to_h
        total_vote_count = items.map { |item| item[:total_vote_count] }.reduce(:+)
        content = parties.map do |party|
          item = ApiResponseModels::CustomOstruct.new
          item.id = party.id
          item.party_name = party.title
          item.votes = party_count_hash[party.id]
          item.party_abbreviation = party.abbreviation
          item.percentage = total_vote_count == 0 ? 0 : party_count_hash[party.id].to_f * 100.to_f / total_vote_count.to_f
          item.party_image_obj = party.party_image_obj
          item
        end
        content.sort_by! { |item| -1 * item.votes }
      end
      content
    end

    def self.top_parties_of_constituency_pc(election_id = nil, pc_id = nil)
      content = []
      unless pc_id.blank?
        query = <<-eos
            select sum("vote_count") as "total_vote_count" from (
                select last("total_vote_count") as "vote_count",
                "candidature_id", "party_id", "pc_id", "election_id", "state_id" from
                "#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}"
                where "pc_id" = '#{pc_id}'
                and "ac_id" = 'none'
                and "election_id" = '#{election_id}'
                and time >= now() - 30d and time <= now()
                group by "candidature_id", time(1d) fill(previous)
              ) group by "party_id"
            eos
        data = Influx::Config::DB_REGULAR.query query
        items = data.map do |point|
          {
            party_id: point["tags"]["party_id"],
            total_vote_count: point["values"].first["total_vote_count"].to_i
          }
        end
        items.select! { |item| item[:total_vote_count] > 0 }
        items.sort_by! { |item| -1 * item[:total_vote_count] }
        party_ids = items.map { |item| item[:party_id] }
        parties = Party.where(id: party_ids)
        party_count_hash = items.map { |item| [item[:party_id], item[:total_vote_count]] }.to_h
        total_vote_count = items.map { |item| item[:total_vote_count] }.reduce(:+)
        content = parties.map do |party|
          item = ApiResponseModels::CustomOstruct.new
          item.id = party.id
          item.party_name = party.title
          item.votes = party_count_hash[party.id]
          item.party_abbreviation = party.abbreviation
          item.percentage = total_vote_count == 0 ? 0 : party_count_hash[party.id].to_f * 100.to_f / total_vote_count.to_f
          item.party_image_obj = party.party_image_obj
          item
        end
        content.sort_by! { |item| -1 * item.votes }
      end
      content
    end

    def self.top_parties_of_state_ac(election_id = nil, state_id = nil)
      # top parties in a state assembly constituencies wise
      party_content = []
      items = []
      unless state_id.blank?
        query = <<-eos
              select sum("vote_count") as "total_vote_count" from (
                select last("total_vote_count") as "vote_count", "candidature_id", "party_id",
                "ac_id", "pc_id", "election_id", "state_id" from "#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}"
                where "state_id" = '#{state_id}' and "election_id" = '#{election_id}'
                and "ac_id" <> 'none'
                and time >= now() - 30d and time <= now()
                group by "candidature_id", time(1d) fill(previous)
              )
              group by "party_id", "ac_id"
            eos
        data = Influx::Config::DB_REGULAR.query query
        party_hash = {}
        constituency_hash = {}
        party_ids = []
        items = data.map do |point|
          item = {
            party_id: point["tags"]["party_id"],
            ac_id: point["tags"]["ac_id"],
            total_vote_count: point["values"].first["total_vote_count"].to_i
          }
          party_hash[item[:party_id]] = if party_hash[item[:party_id]].blank?
                                          item[:total_vote_count]
                                        else
                                          party_hash[item[:party_id]] + item[:total_vote_count]
                                        end
          party_ids << item[:party_id]
          if constituency_hash[item[:ac_id]].blank?
            constituency_hash[item[:ac_id]] = {
              constituency_id: item[:ac_id],
              party_id: item[:party_id],
              total_vote_count: item[:total_vote_count]
            }
          else
            if constituency_hash[item[:ac_id]][:total_vote_count] < item[:total_vote_count]
              constituency_hash[item[:ac_id]] = {
                constituency_id: item[:ac_id],
                party_id: item[:party_id],
                total_vote_count: item[:total_vote_count]
              }
            end
          end
          item
        end
      end
      parties = Party.where(id: party_ids)
      total_vote_count = party_hash.values.reduce(:+)
      party_content = parties.map do |party|
        item = ApiResponseModels::CustomOstruct.new
        item.id = party.id
        item.party_name = party.title
        item.votes = party_hash[party.id]
        item.party_abbreviation = party.abbreviation
        item.percentage = total_vote_count == 0 ? 0 : party_hash[party.id].to_f * 100.to_f / total_vote_count.to_f
        item.party_image_obj = party.party_image_obj
        item
      end
      response = ApiResponseModels::CustomOstruct.new
      top_parties_by_votes = party_content.select { |i| i.votes > 0 }
      response.top_parties_by_votes = top_parties_by_votes.sort_by { |i| -1 * i.votes }
      constituencies =
        constituency_hash.values
                         .sort_by! { |i| -1 * i[:total_vote_count] }
                         .map do |i|
          item = ApiResponseModels::CustomOstruct.new
          item.id = i[:constituency_id]
          item.party_id = i[:party_id]
          item.votes = i[:total_vote_count]
          item
        end
      response.constituencies = constituencies

      top_parties_by_constituencies = constituencies.each_with_object({}) do |obj, acc|
        if acc.key? obj.party_id
          acc[obj.party_id].constituencies_won = acc[obj.party_id].constituencies_won + 1
        else
          item = ApiResponseModels::CustomOstruct.new
          item.party_id = obj.party_id
          item.constituencies_won = 1
          acc[obj.party_id] = item
        end
        acc
      end
      top_parties_by_constituencies = top_parties_by_constituencies.values.sort_by { |i| -1 * i.constituencies_won }
      response.top_parties_by_constituencies = top_parties_by_constituencies
      response
    end

    def self.top_parties_of_nation(election_id = nil)
      # top parties in a state assembly constituencies wise
      party_content = []
      items = []
      query = <<-eos
              select sum("vote_count") as "total_vote_count" from (
                select last("total_vote_count") as "vote_count", "candidature_id", "party_id",
                "ac_id", "pc_id", "election_id", "state_id" from "#{Influx::Config::NAME_DB_REGULAR}"."autogen"."#{Influx::Config::MEASUREMENT_CANDIDATURE_POPULARITY}"
                where "election_id" = '#{election_id}'
                and "ac_id" = 'none'
                and time >= now() - 30d and time <= now()
                group by "candidature_id", time(1d) fill(previous)
              )
              group by "party_id", "pc_id"
            eos
      data = Influx::Config::DB_REGULAR.query query
      party_hash = {}
      constituency_hash = {}
      party_ids = []
      items = data.map do |point|
        item = {
          party_id: point["tags"]["party_id"],
          pc_id: point["tags"]["pc_id"],
          total_vote_count: point["values"].first["total_vote_count"].to_i
        }
        party_hash[item[:party_id]] = if party_hash[item[:party_id]].blank?
                                        item[:total_vote_count]
                                      else
                                        party_hash[item[:party_id]] + item[:total_vote_count]
                                      end
        party_ids << item[:party_id]
        if constituency_hash[item[:pc_id]].blank?
          constituency_hash[item[:pc_id]] = {
            constituency_id: item[:pc_id],
            party_id: item[:party_id],
            total_vote_count: item[:total_vote_count]
          }
        else
          if constituency_hash[item[:pc_id]][:total_vote_count] < item[:total_vote_count]
            constituency_hash[item[:pc_id]] = {
              constituency_id: item[:pc_id],
              party_id: item[:party_id],
              total_vote_count: item[:total_vote_count]
            }
          end
        end
        item
      end
      parties = Party.where(id: party_ids)
      total_vote_count = party_hash.values.reduce(:+)
      party_content = parties.map do |party|
        item = ApiResponseModels::CustomOstruct.new
        item.id = party.id
        item.party_name = party.title
        item.votes = party_hash[party.id]
        item.party_abbreviation = party.abbreviation
        item.percentage = total_vote_count == 0 ? 0 : party_hash[party.id].to_f * 100.to_f / total_vote_count.to_f
        item.party_image_obj = party.party_image_obj
        item
      end
      response = ApiResponseModels::CustomOstruct.new
      top_parties_by_votes = party_content.select { |i| i.votes > 0 }
      response.top_parties_by_votes = top_parties_by_votes.sort_by { |i| -1 * i.votes }
      constituencies =
        constituency_hash.values
                         .sort_by! { |i| -1 * i[:total_vote_count] }
                         .map do |i|
          item = ApiResponseModels::CustomOstruct.new
          item.id = i[:constituency_id]
          item.party_id = i[:party_id]
          item.votes = i[:total_vote_count]
          item
        end
      response.constituencies = constituencies

      top_parties_by_constituencies = constituencies.each_with_object({}) do |obj, acc|
        if acc.key? obj.party_id
          acc[obj.party_id].constituencies_won = acc[obj.party_id].constituencies_won + 1
        else
          item = ApiResponseModels::CustomOstruct.new
          item.party_id = obj.party_id
          item.constituencies_won = 1
          acc[obj.party_id] = item
        end
        acc
      end
      top_parties_by_constituencies = top_parties_by_constituencies.values.sort_by { |i| -1 * i.constituencies_won }
      response.top_parties_by_constituencies = top_parties_by_constituencies
      response
    end
  end
end
