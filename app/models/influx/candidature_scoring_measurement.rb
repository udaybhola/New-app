module Influx
  class CandidatureScoringMeasurement
    include Influx::Measurable

    def ingest_candidature_created(activity)
      candidature = activity.activable
      data = {
        values:    { score: candidature.initial_votes },
        tags:      { state_id: candidature.constituency.country_state.id,
                     candidature_id: candidature.id,
                     candidate_id: candidature.candidate.id,
                     election_id: candidature.election_id,
                     party_id: candidature.party.id },
        timestamp: activity.created_at.to_i
      }
      if candidature.constituency.is_assembly?
        data[:tags][:ac_id] = candidature.constituency.id
        data[:tags][:pc_id] = candidature.constituency.parent.id
      elsif candidature.constituency.is_parliament?
        data[:tags][:ac_id] = 'none'
        data[:tags][:pc_id] = candidature.constituency.id
      end
      db.client.write_point(name, data)
    end

    def delete_candidature_measurement(candidature_id)
      query = <<-eos
        delete from #{name} where candidature_id = '#{candidature_id}'
      eos

      data = db.client.query query
      ## influx returns empty if successful
      data.empty?
    end

    def ingest_candidature_initial_votes(candidature)
      data = {
        values:    { score: candidature.initial_votes },
        tags:      { state_id: candidature.constituency.country_state.id,
                     candidature_id: candidature.id,
                     candidate_id: candidature.candidate.id,
                     election_id: candidature.election_id,
                     party_id: candidature.party.id,
                     vote_type: 'initial' },
        timestamp: Time.now.to_i
      }
      if candidature.constituency.is_assembly?
        data[:tags][:ac_id] = candidature.constituency.id
        data[:tags][:pc_id] = candidature.constituency.parent.id
      elsif candidature.constituency.is_parliament?
        data[:tags][:ac_id] = 'none'
        data[:tags][:pc_id] = candidature.constituency.id
      end
      db.client.write_point(name, data)
    end

    def delete_candidature_initial_votes(candidature)
      delete_query = <<-eos
        delete from #{name} where "vote_type" = 'initial'
        and
        "candidature_id" = '#{candidature.id}'
      eos
      db.client.query delete_query
    end

    def ingest_candidature_voted(activity)
      candidate_vote = activity.activable
      is_new_vote = candidate_vote.is_valid && candidate_vote.previous_vote.nil?
      canceled_vote = !candidate_vote.is_valid && !candidate_vote.previous_vote.nil?
      is_old_vote_which_got_changed = !candidate_vote.new_vote.nil?

      data = {
        values:    { score: canceled_vote ? -1 : 1 },
        tags:      { state_id: candidate_vote.candidature.constituency.country_state.id,
                     candidature_id: candidate_vote.candidature.id,
                     candidate_id: candidate_vote.candidature.candidate.id,
                     election_id: candidate_vote.candidature.election_id,
                     party_id: candidate_vote.candidature.party.id },
        timestamp: candidate_vote.created_at.to_i
      }
      if candidate_vote.candidature.constituency.is_assembly?
        data[:tags][:ac_id] = candidate_vote.candidature.constituency.id
        data[:tags][:pc_id] = candidate_vote.candidature.constituency.parent.id
      elsif candidate_vote.candidature.constituency.is_parliament?
        data[:tags][:ac_id] = 'none'
        data[:tags][:pc_id] = candidate_vote.candidature.constituency.id
      end

      if is_new_vote || canceled_vote || is_old_vote_which_got_changed
        db.client.write_point(name, data)
      else
        previous_vote = candidate_vote.previous_vote
        data[:series] = name
        prev_data = {
          series: name,
          values:    { score: -1 },
          tags:      { state_id: previous_vote.candidature.constituency.country_state.id,
                       candidature_id: previous_vote.candidature.id,
                       candidate_id: previous_vote.candidature.candidate.id,
                       election_id: previous_vote.candidature.election_id,
                       party_id: previous_vote.candidature.party.id },
          timestamp: candidate_vote.created_at.to_i
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
        db.client.write_points(content, precision)
      end
    end

    def name
      'measurement_candidature_scoring'
    end

    def tags
      %w[score state_id candidate_id candidature_id election_id party_id ac_id pc_id]
    end

    def tags_without_score
      tags - ["score"]
    end

    def all_tags_query_string
      tags.map { |i| %("#{i}") }.join(", ")
    end

    def all_tags_without_score_query_string
      tags_without_score.map { |i| %("#{i}") }.join(", ")
    end

    def popular_candidatures(options = {})
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      data = []
      if constituency_id.nil? && state_id.blank?
        data = top_candidates_of_nation(options.merge(election_id: CountryState.current_parliamentary_election.id)) if CountryState.current_parliamentary_election
      else
        const = Constituency.find(constituency_id)
        candidature_count = options[:top] ? options[:top] : const.candidatures.count == 0 ? 15 : const.candidatures.count
        if const.is_assembly? && state_id.blank?
          data = top_candidates_of_ac(options.merge(ac_id: const.id, election_id: const.current_election.id, top: candidature_count)) if const.current_election
        elsif const.is_assembly? && !state_id.blank?
          data = top_candidates_of_state(options.merge(state_id: const.country_state.id, election_id: const.country_state.current_assembly_election.id, top: candidature_count)) if const.country_state.current_assembly_election
        elsif const.is_parliament? && state_id.blank?
          data = top_candidates_of_pc(options.merge(pc_id: const.id, election_id: CountryState.current_parliamentary_election.id, top: candidature_count)) if CountryState.current_parliamentary_election
        end
      end
      if options[:sort_by] && options[:sort_by] == 'votes_asc'
        data = data.reverse
      elsif options[:sort_by] && options[:sort_by] == 'party'
        data = data.sort_by { |candidature| [candidature.party_abbreviation, candidature.votes] }
      end
      data
    end

    def top_parties(options = {})
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      data = if constituency_id.nil? && state_id.nil?
               return [] if CountryState.current_parliamentary_election.blank?
               top_parties_of_constituency_nation(options.merge(election_id: CountryState.current_parliamentary_election.id))
             elsif constituency_id.nil?
               election = CountryState.find(state_id).current_assembly_election
               return [] if election.blank?
               top_parties_of_constituency_state(options.merge(state_id: state_id, election_id: election.id))
             else
               const = Constituency.find(constituency_id)
               election = Constituency.find(constituency_id).current_election
               if const.is_assembly?
                 return [] if election.blank?
                 top_parties_of_constituency_ac(options.merge(ac_id: constituency_id, election_id: election.id))
               elsif const.is_parliament?
                 return [] if election.blank?
                 top_parties_of_constituency_pc(options.merge(pc_id: constituency_id, election_id: election.id))
               end
             end
      data
    end

    def top_parties_constituency_wise(options = {})
      state_id = options[:state_id]
      is_state = false
      if state_id
        is_state = true
        cs = CountryState.find(state_id)
        election_id = cs.current_assembly_election.id
        constituencies = cs.assembly_constituencies.order('name asc')
        query = <<-eos
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" <> 'none'
          and
          "election_id" = '#{election_id}'
          and
          "state_id" = '#{state_id}'
          and
          time >= now() - 520w and time <= now()
          group by "party_id", "ac_id"
        eos
      else
        election_id = CountryState.current_parliamentary_election.id
        constituencies = CountryState.parliamentary_constituencies.order('name asc')
        query = <<-eos
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = 'none'
          and
          "pc_id" <> 'none'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "party_id", "pc_id"
        eos
      end

      data = db.client.query query
      constituency_hash = {}
      data.each do |item|
        const_id = item["tags"][is_state ? "ac_id" : "pc_id"]
        score = item["values"][0]["score"]
        party_id = item["tags"]["party_id"]
        if constituency_hash.key? const_id
          party = Party.find(party_id)
          const = Constituency.find(const_id)
          constituency_hash[const_id][:parties] << {
            party: party,
            score: score
          }
          constituency_hash[const_id][:total_score] = constituency_hash[const_id][:total_score] + score
        else
          party = Party.find(party_id)
          constituency_hash[const_id] = {}
          constituency_hash[const_id][:total_score] = score
          constituency_hash[const_id][:parties] = [{
            party: party,
            score: score
          }]
        end
      end
      result = constituencies.map do |const|
        item = ApiResponseModels::CustomOstruct.new
        item.name = const.name
        item.id = const.id
        if constituency_hash.key? const.id
          item.parties = constituency_hash[const.id][:parties].map do |_party_item|
            party_item = ApiResponseModels::CustomOstruct.new
            party_item.id = _party_item[:party].id
            party_item.name = _party_item[:party].name
            party_item.abbreviation = _party_item[:party].abbreviation
            party_item.score = _party_item[:score]
            party_item.color = _party_item[:party].color
            party_item
          end
          item.total_score = constituency_hash[const.id][:total_score]
        else
          item.parties = []
          item.total_score = 0
        end
        item.parties = item.parties.sort_by { |item| -1 * item.score }
        item
      end

      result
    end

    def parties_stats(options = {})
      resolution = options[:resolution]
      party_ids = options[:party_ids]
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]

      time_start = "'2018-01-01T00:00:00Z'"
      time_end = "now()"
      group_by = "1w"

      case resolution
      when "last_24_hours"
        time_start = "now() - 24h"
        epoch = Time.at(0)
        now = Time.now
        minute_span = 60
        total_minutes = ((now - epoch) / minute_span).to_i
        grouping = 60
        offset = (total_minutes % grouping) - grouping
        group_by = "#{grouping}m, #{offset}m"

      when "last_week"
        time_start = "now() - 1w"

        epoch = Time.at(0)
        now = Time.now
        hour_span = 60 * 60
        total_hours = ((now - epoch) / hour_span).to_i
        grouping = 24
        offset = (total_hours % grouping) - grouping
        group_by = "#{grouping}h, #{offset}h"

      when "last_month"
        time_start = "now() - 5w"

        epoch = Time.at(0)
        now = Time.now
        day_span = 24 * 60 * 60
        total_days = ((now - epoch) / day_span).to_i
        grouping = 7
        offset = (total_days % grouping) - grouping
        group_by = "#{grouping}d, #{offset}d"

      when "since_the_beginning"
        epoch = Time.at(0)
        now = Time.now
        day_span = 24 * 60 * 60
        total_days = ((now - epoch) / day_span).to_i
        grouping = 30
        offset = (total_days % grouping) - grouping
        group_by = "#{grouping}d, #{offset}d"
      else
        return []
      end

      query = ""

      if constituency_id.nil? && state_id.nil?
        election_id = CountryState.current_parliamentary_election.id
        election = Election.find(election_id)
        parties_where = election.candidatures.select(:party_id).distinct.map(&:party_id).map { |party_id| %("party_id" = '#{party_id}') }.join(" OR ")
        query = <<-eos
            select  cumulative_sum(sum("score")) as "score" from #{autogen_db}
            where "ac_id" = 'none'
            and
            "election_id" = '#{election_id}'
            and
            #{parties_where}
            and
            time >= #{time_start} and time <= #{time_end}
            group by "party_id", time(#{group_by}) fill(0)
        eos
      elsif constituency_id.nil?
        election_id = CountryState.find(state_id).current_assembly_election.id
        election = Election.find(election_id)
        parties_where = election.candidatures.select(:party_id).distinct.map(&:party_id).map { |party_id| %("party_id" = '#{party_id}') }.join(" OR ")
        query = <<-eos
            select  cumulative_sum(sum("score")) as "score" from #{autogen_db}
            where "state_id" = '#{state_id}'
            and
            "ac_id" <> 'none'
            and
            "election_id" = '#{election_id}'
            and
            #{parties_where}
            and
            time >= #{time_start} and time <= #{time_end}
            group by "party_id", time(#{group_by}) fill(0)
        eos
      else
        const = Constituency.find(constituency_id)
        election_id = const.current_election.id
        election = Election.find(election_id)
        parties_where = election.candidatures.select(:party_id).distinct.map(&:party_id).map { |party_id| %("party_id" = '#{party_id}') }.join(" OR ")
        query = if const.is_assembly?
                  <<-eos
                    select  cumulative_sum(sum("score")) as "score" from #{autogen_db}
                    where "ac_id" = '#{constituency_id}'
                    and
                    "election_id" = '#{election_id}'
                    and
                    #{parties_where}
                    and
                    time >= #{time_start} and time <= #{time_end}
                    group by "party_id", time(#{group_by}) fill(0)
                  eos
                elsif const.is_parliament?
                  <<-eos
                    select  cumulative_sum(sum("score")) as "score" from #{autogen_db}
                    where "ac_id" = 'none'
                    and
                    "pc_id" = '#{constituency_id}'
                    and
                    "election_id" = '#{election_id}'
                    and
                    #{parties_where}
                    and
                    time >= #{time_start} and time <= #{time_end}
                    group by "party_id", time(#{group_by}) fill(0)
                  eos
                end
      end
      data = db.client.query query
      window_count = 0
      result = data.map do |point|
        item = ApiResponseModels::CustomOstruct.new
        item.party_id = point["tags"]["party_id"]
        item.values = point["values"].map do |score_point|
          sp = ApiResponseModels::CustomOstruct.new
          sp.time = score_point["time"]
          sp.score = score_point["score"]
          sp
        end
        window_count = item.values.count > window_count ? item.values.count : window_count
        item
      end
      totals = []
      window_count.times do |index|
        totals << result.map { |item| item.values[index].score }.reduce(&:+)
      end
      result.each do |item|
        item.values.each_with_index do |value, index|
          value.percentage = totals[index] == 0 ? 0 : value.score.to_f * 100.to_f / totals[index].to_f
        end
      end
      result = result.select { |item| party_ids.include? item.party_id }
      result
    end

    def top_candidates_of_ac(options = {})
      return [] if options[:ac_id].blank? || options[:election_id].blank?
      ac_id = options[:ac_id]
      election_id = options[:election_id]
      user_id = options[:user_id]
      topN = 1000
      query = <<-eos
        select top("score", "candidature_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = '#{ac_id}'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "candidature_id"
        )
      eos
      data = db.client.query query
      build_top_candidates_response_from_data(data, election_id, user_id, options[:top], ac_id)
    end

    def top_candidates_of_state(options = {})
      return [] if options[:state_id].blank? || options[:election_id].blank?
      state_id = options[:state_id]
      election_id = options[:election_id]
      user_id = options[:user_id]
      topN = 1000
      query = <<-eos
        select top("score", "candidature_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" <> 'none'
          and
          "election_id" = '#{election_id}'
          and
          "state_id" = '#{state_id}'
          and
          time >= now() - 520w and time <= now()
          group by "candidature_id"
        )
      eos
      data = db.client.query query
      build_top_candidates_response_from_data(data, election_id, user_id, options[:top], nil, state_id)
    end

    def top_candidates_of_pc(options = {})
      pc_id = options[:pc_id]
      election_id = options[:election_id]
      user_id = options[:user_id]
      topN = 1000
      query = <<-eos
        select top("score", "candidature_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = 'none'
          and
          "pc_id" = '#{pc_id}'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "candidature_id"
        )
      eos
      data = db.client.query query
      build_top_candidates_response_from_data(data, election_id, user_id, options[:top], nil)
    end

    def top_candidates_of_nation(options = {})
      return [] if options[:election_id].blank?
      election_id = options[:election_id]
      user_id = options[:user_id]
      topN = 1000
      query = <<-eos
        select top("score", "candidature_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = 'none'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "candidature_id"
        )
      eos
      data = db.client.query query
      build_top_candidates_response_from_data(data, election_id, user_id, options[:top])
    end

    def top_parties_of_constituency_ac(options = {})
      return [] if options[:ac_id].blank? || options[:election_id].blank?
      ac_id = options[:ac_id]
      election_id = options[:election_id]
      topN = 600 # should encompass all parties that can contest in this constituency
      query = <<-eos
        select top("score", "party_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = '#{ac_id}'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "party_id"
        )
      eos

      data = db.client.query query
      return [] if data.empty?
      items = data.first["values"].map do |point|
        {
          party_id: point["party_id"],
          total_vote_count: point["score"].to_i
        }
      end
      items.select! { |item| item[:total_vote_count] >= 0 }
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
        item.party_color = party.color
        item
      end
      content.sort_by { |item| -1 * item.votes }
    end

    def top_parties_of_constituency_pc(options = {})
      return [] if options[:pc_id].blank? || options[:election_id].blank?
      pc_id = options[:pc_id]
      election_id = options[:election_id]
      topN = 600 # should encompass all parties that can contest in this constituency
      query = <<-eos
        select top("score", "party_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "pc_id" = '#{pc_id}'
          and
          "ac_id" = 'none'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "party_id"
        )
      eos

      data = db.client.query query
      return [] if data.empty?
      items = data.first["values"].map do |point|
        {
          party_id: point["party_id"],
          total_vote_count: point["score"].to_i
        }
      end
      items.select! { |item| item[:total_vote_count] >= 0 }
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
        item.party_color = party.color
        item
      end
      content.sort_by { |item| -1 * item.votes }
    end

    def top_parties_of_constituency_state(options = {})
      return [] if options[:state_id].blank? || options[:election_id].blank?
      state_id = options[:state_id]
      election_id = options[:election_id]
      country_state = CountryState.find(state_id)
      topN = country_state.assembly_constituencies.count * 100 # 50 parties contest on an average

      query = <<-eos
        select top("score", "party_id", "ac_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" <> 'none'
          and
          "state_id" = '#{state_id}'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "party_id", "ac_id"
        )
      eos

      data = db.client.query query
      build_top_parties(data, country_state.assembly_constituencies.count, election_id, state_id)
    end

    def top_parties_of_constituency_nation(options = {})
      return [] if options[:election_id].blank?
      election_id = options[:election_id]
      topN = Constituency.parliamentary.count * 100 # 50 parties contest on an average

      query = <<-eos
        select top("score", "party_id", "pc_id", #{topN}) as "score" from
        (
          select sum("score") as "score" from #{autogen_db}
          where "ac_id" = 'none'
          and
          "election_id" = '#{election_id}'
          and
          time >= now() - 520w and time <= now()
          group by "party_id", "pc_id"
        )
      eos

      data = db.client.query query
      build_top_parties(data, Constituency.parliamentary.count, election_id)
    end

    def build_top_parties(data, top, _election_id, state_id = nil)
      return nil if data.empty?
      topN = top || 15
      party_hash = {}
      constituency_hash = {}
      party_ids = []
      items = data.first["values"].map do |point|
        item = {
          party_id: point["party_id"],
          ac_id: point["ac_id"],
          pc_id: point["pc_id"],
          total_vote_count: point["score"].to_i
        }
        party_hash[item[:party_id]] = if party_hash[item[:party_id]].blank?
                                        item[:total_vote_count]
                                      else
                                        party_hash[item[:party_id]] + item[:total_vote_count]
                                      end
        party_ids << item[:party_id]

        item_sym = state_id.blank? ? :pc_id : :ac_id
        if constituency_hash[item[item_sym]].blank?
          constituency_hash[item[item_sym]] = {
            constituency_id: item[item_sym],
            party_id: item[:party_id],
            total_vote_count: item[:total_vote_count],
            all_votes_count: item[:total_vote_count]
          }
        else
          if constituency_hash[item[item_sym]][:total_vote_count] < item[:total_vote_count]
            constituency_hash[item[item_sym]] = {
              constituency_id: item[item_sym],
              party_id: item[:party_id],
              total_vote_count: item[:total_vote_count]
            }
          end
          constituency_hash[item[item_sym]] = constituency_hash[item[item_sym]].merge(all_votes_count: constituency_hash[item[item_sym]][:all_votes_count] + item[:total_vote_count])
        end
        item
      end

      parties = Party.where(id: party_ids)
      total_vote_count = constituency_hash.values.map { |i| i[:all_votes_count] }.reduce(:+)
      party_content = parties.map do |party|
        item = ApiResponseModels::CustomOstruct.new
        item.id = party.id
        item.party_name = party.title
        item.votes = party_hash[party.id]
        item.party_abbreviation = party.abbreviation
        item.percentage = total_vote_count == 0 ? 0 : party_hash[party.id].to_f * 100.to_f / total_vote_count.to_f
        item.party_image_obj = party.party_image_obj
        item.party_color = party.color
        item
      end
      response = ApiResponseModels::CustomOstruct.new
      top_parties_by_votes = party_content.select { |i| i.votes >= 0 }
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
          acc[obj.party_id].constituencies_won = acc[obj.party_id].constituencies_won + (obj.votes > 0 ? 1 : 0)
        else
          item = ApiResponseModels::CustomOstruct.new
          item.party_id = obj.party_id
          item.constituencies_won = obj.votes > 0 ? 1 : 0
          item.votes = obj.votes
          acc[obj.party_id] = item
        end
        acc
      end
      top_parties_by_constituencies = top_parties_by_constituencies.values.sort_by { |i| -1 * i.constituencies_won }
      response.top_parties_by_constituencies = top_parties_by_constituencies[0..topN]
      response
    end

    def build_top_candidates_response_from_data(data, _election_id, user_id, top = 15, _ac_id = nil, _state_id = nil)
      return [] if data.empty?
      topN = top || 15
      values = data.first["values"]
                   .select { |item| item["score"] >= 0 }
                   .sort_by { |item| -item["score"] }
      vote_hash = values.map { |item| [item["candidature_id"], Candidature.find(item["candidature_id"]).total_votes] }.to_h
      candidatures = Candidature.where(
        id: values[0..topN].map { |item| item["candidature_id"] }
      )
      total_votes = vote_hash.values.reduce(:+)

      candidates = []
      candidatures.each do |candidature|
        candidate = candidature.candidate
        party = candidature.party
        vote_count = vote_hash[candidature.id]
        is_voted_by_me = candidature.is_voted_by_user(user_id)
        party_and_support_info = if is_voted_by_me
                                   user = User.find(user_id)
                                   ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(user.profile, candidature.candidate, candidature.constituency, user, candidature)
                                 end
        label = candidate.label.nil? ? nil : { name: candidate.label.name, color: candidate.label.color }
        candidates << ApiResponseModels::Api::V1::CandidatesData.new(
          candidature.id, candidate.id, candidate.profile.name,
          candidature.declared, party.abbreviation,
          candidate.profile.profile_pic, party.image,
          vote_count,
          total_votes.zero? ? 0 : (vote_count.to_f / total_votes.to_f) * 100.to_f,
          false, is_voted_by_me, party_and_support_info, candidature.constituency_id, !candidate.profile.cover_photo_obj.nil?, label
        )
      end
      candidates.sort_by! { |item| -item.votes }[0..topN]
    end
  end
end
