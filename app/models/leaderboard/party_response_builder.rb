module Leaderboard
  module PartyResponseBuilder
    extend ActiveSupport::Concern

    def party_vote_count_hash(key)
      elems = redis.zrevrange key, 0, -1, with_scores: true
      party_count_hash = elems.to_h
      total_vote_count = party_count_hash.values.reduce(:+)
      parties = ::Party.where(id: party_count_hash.keys)
      content = parties.map do |party|
        item = ApiResponseModels::CustomOstruct.new
        item.id = party.id
        item.party_name = party.title
        item.votes = party_count_hash[party.id]
        item.party_abbreviation = party.abbreviation
        item.percentage = total_vote_count.zero? ? 0 : party_count_hash[party.id].to_f * 100.to_f / total_vote_count.to_f
        item.party_image_obj = party.party_image_obj
        item.party_color = party.color
        item
      end
      content.sort_by { |item| -1 * item.votes }
    end

    def party_seat_count_hash(vote_key, seat_key)
      elems = redis.zrevrange vote_key, 0, -1, with_scores: true
      party_count_hash = elems.to_h

      elems = redis.zrevrange seat_key, 0, -1, with_scores: true
      party_count_hash = elems.to_h
      parties = ::Party.where(id: party_count_hash.keys)
      content = parties.map do |party|
        item = ApiResponseModels::CustomOstruct.new
        item.party_id = party.id
        item.constituencies_won = party_count_hash[party.id]
        item.votes = party_count_hash[party.id]
        item
      end
      content.sort_by { |item| -1 * item.constituencies_won }
    end

    def build_constituency_response(key)
      party_vote_count_hash(key)
    end

    def build_state_response(options = {})
      state_id = options[:state_id]
      cs = CountryState.find(state_id)
      return [] if cs.blank?
      election = cs.current_assembly_election

      key = votes_assembly_key(cs, election)
      party_content = party_vote_count_hash(key)

      response = ApiResponseModels::CustomOstruct.new
      response.top_parties_by_votes = party_content
      constituencies_hash = {}
      cs.assembly_constituencies.each do |const|
        key = votes_constituency_assembly_key(cs, const, election)
        elems = redis.zrevrange key, 0, 0, with_scores: true
        unless elems.empty?
          item = ApiResponseModels::CustomOstruct.new
          item.id = const.id
          item.party_id = elems[0][0]
          item.votes = elems[0][1]
          constituencies_hash[const.id] = item
        end
      end
      response.constituencies = constituencies_hash.values
      party_seat_count_hash = party_seat_count_hash(key, seats_assembly_key(cs, election))
      response.top_parties_by_constituencies = party_seat_count_hash
      response
    end

    def build_nation_response
      election = CountryState.current_parliamentary_election
      return [] if election.blank?

      key = votes_parliament_key(election)
      party_content = party_vote_count_hash(key)

      response = ApiResponseModels::CustomOstruct.new
      response.top_parties_by_votes = party_content
      constituencies_hash = {}
      CountryState.parliamentary_constituencies.each do |const|
        key = votes_constituency_parliament_key(const.country_state, const, election)
        elems = redis.zrevrange key, 0, 0, with_scores: true
        unless elems.blank?
          item = ApiResponseModels::CustomOstruct.new
          item.id = const.id
          item.party_id = elems[0][0]
          item.votes = elems[0][1]
          constituencies_hash[const.id] = item
        end
      end
      response.constituencies = constituencies_hash.values
      party_seat_count_hash = party_seat_count_hash(key, seats_parliament_key(election))
      response.top_parties_by_constituencies = party_seat_count_hash
      response
    end
  end
end
