module Leaderboard
  module CandidatureQuery
    extend ActiveSupport::Concern
    include Leaderboard::CandidatureResponseBuilder

    def current_parliament_election
      CountryState.current_parliamentary_election
    end

    def candidatures_of_current_parliament_election(options = {})
      redis.zrevrange parliament_key(current_parliament_election), 0, options[:top] || -1, with_scores: true
    end

    def candidatures_of_current_assembly_election(state_code = '', options = {})
      cs = CountryState.find_by(code: state_code)
      elems = []
      if cs
        key = assembly_key(cs, cs.current_assembly_election)
        elems = redis.zrevrange key, 0, options[:top] || -1, with_scores: true
      end
      elems.to_h
    end

    def candidatures_of_assembly_constituency(ac_id = '', election_id = '', options = {})
      const = Constituency.find(ac_id)
      election = Election.find(election_id)
      elems = []
      if const && election
        key = constituency_assembly_key(const.country_state, const, election)
        elems = redis.zrevrange key, 0, options[:top] || -1, with_scores: true
      end
      elems.to_h
    end

    def candidatures_of_parliamentary_constituency(pc_id = '', election_id = '', options = {})
      const = Constituency.find(pc_id)
      election = Election.find(election_id)
      elems = []
      if const && election
        key = constituency_parliament_key(const.country_state, const, election)
        elems = redis.zrevrange key, 0, options[:top] || -1, with_scores: true
      end
      elems.to_h
    end

    def candidatures_of_nation(election_id = '', options = {})
      election = Election.find(election_id)
      elems = []
      if election
        key = parliament_key(election)
        elems = redis.zrevrange key, 0, options[:top] || -1, with_scores: true
      end
      elems.to_h
    end

    def candidatures_of_state(state_id = '', election_id = '', options = {})
      election = Election.find(election_id)
      cs = CountryState.find(state_id)
      elems = []
      if election
        key = assembly_key(cs, election)
        elems = redis.zrevrange key, 0, options[:top] || -1, with_scores: true
      end
      elems.to_h
    end

    def popular_candidatures(options = {})
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      data = []

      candidature_display_counts = MobileAppSetting.find_by(key: "CANDIDATURE_DISPLAY_COUNTS")

      if constituency_id.nil? && state_id.blank?
        election_id = CountryState.current_parliamentary_election.id
        candidature_count = candidature_display_count(candidature_display_counts, options, "national")
        redis_data = candidatures_of_nation(election_id, top: candidature_count - 1)
        data = build_top_candidates_response(redis_data, election_id: election_id, user_id: options[:user_id])
      else
        const = Constituency.find(constituency_id)
        if const.is_assembly? && const.current_election && state_id.blank?
          candidature_count = candidature_display_count(candidature_display_counts, options, "assembly")
          redis_data = candidatures_of_assembly_constituency(const.id, const.current_election.id, top: candidature_count - 1)
          data = build_top_candidates_response(redis_data, election_id: const.current_election.id, user_id: options[:user_id], ac_id: const.id)
        elsif const.is_assembly? && const.country_state.current_assembly_election && !state_id.blank?
          election_id = const.country_state.current_assembly_election.id
          state_id = const.country_state.id
          candidature_count = candidature_display_count(candidature_display_counts, options, "state")
          redis_data = candidatures_of_state(state_id, election_id, top: candidature_count - 1)
          data = build_top_candidates_response(redis_data, election_id: election_id, user_id: options[:user_id], state_id: state_id)
        elsif const.is_parliament? && state_id.blank?
          candidature_count = candidature_display_count(candidature_display_counts, options, "parliament")
          redis_data = candidatures_of_parliamentary_constituency(const.id, const.current_election.id, top: candidature_count - 1)
          data = build_top_candidates_response(redis_data, election_id: const.current_election.id, user_id: options[:user_id], pc_id: const.id)
        end
      end
      if options[:sort_by] && options[:sort_by] == 'votes_asc'
        data = data.reverse
      elsif options[:sort_by] && options[:sort_by] == 'party'
        data = data.sort_by { |candidature| [candidature.party_abbreviation, candidature.votes] }
      end
      data
    end

    private

    def candidature_display_count(candidature_display_counts, options, type)
      candidature_count = if options[:top]
                            options[:top]
                          elsif candidature_display_counts
                            if type == "assembly"
                              candidature_display_counts.voting_booth_mla_candidature_count || 15
                            elsif type == "parliament"
                              candidature_display_counts.voting_booth_mp_candidature_count || 15
                            elsif type == "state"
                              candidature_display_counts.dashboard_state_candidature_count || 15
                            elsif type == "national"
                              candidature_display_counts.dashboard_national_candidature_count || 15
                            else
                              15
                                                end
                          else
                            15
                          end
      candidature_count.to_i
    end
  end
end
