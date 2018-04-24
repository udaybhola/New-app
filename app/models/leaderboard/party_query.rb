module Leaderboard
  module PartyQuery
    extend ActiveSupport::Concern
    include Leaderboard::PartyResponseBuilder

    def current_parliament_election
      CountryState.current_parliamentary_election
    end

    def top_parties_of_constituency_nation(_options = {})
      return [] if CountryState.current_parliamentary_election.blank?
      build_nation_response
    end

    def top_party_of_parliament(parl_const)
      key = votes_constituency_parliament_key(parl_const.country_state, parl_const, CountryState.current_parliamentary_election)
      elems = redis.zrevrange key, 0, 0
      elems.empty? ? "" : elems[0]
    end

    def top_party_of_assembly(const)
      return "" unless const.country_state.current_assembly_election
      key = votes_constituency_assembly_key(const.country_state, const, const.country_state.current_assembly_election)
      elems = redis.zrevrange key, 0, 0
      elems.empty? ? "" : elems[0]
    end

    def top_parties_of_constituency_state(options = {})
      state_id = options[:state_id]
      election = CountryState.find(state_id).current_assembly_election
      if election.blank?
        resp = ApiResponseModels::CustomOstruct.new
        resp.top_parties_by_votes = []
        resp.top_parties_by_constituencies = []
        resp.constituencies = []
        return resp
      end
      build_state_response(options)
    end

    def top_parties_of_constituency(options = {})
      constituency_id = options[:constituency_id]
      const = Constituency.find(constituency_id)
      election = const.current_election
      key = ""
      if const.is_assembly?
        key = votes_constituency_assembly_key(const.country_state, const, election)
      elsif const.is_parliament?
        key = votes_constituency_parliament_key(const.country_state, const, election)
      end
      return [] if key.blank?
      build_constituency_response(key)
    end

    def top_parties(options = {})
      constituency_id = options[:constituency_id]
      state_id = options[:state_id]
      return top_parties_of_constituency_nation(options) if constituency_id.nil? && state_id.nil?
      return top_parties_of_constituency_state(options) if constituency_id.nil?
      top_parties_of_constituency(options)
    end
  end
end
