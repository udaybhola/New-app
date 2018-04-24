module Leaderboard
  module PartyInsertNational
    extend ActiveSupport::Concern

    def update_national_votes_constituency_level(election)
      CountryState.parliamentary_constituencies.each do |const|
        parties_data = group_by_parties(election, const)
        votes_key = votes_constituency_parliament_key(const.country_state, const, election)
        insert_into_redis(parties_data, votes_key)
      end
    end

    def update_national_seats(election)
      party_counts = {}
      CountryState.parliamentary_constituencies.each do |const|
        votes_key = votes_constituency_parliament_key(const.country_state, const, election)
        elems = redis.zrevrange votes_key, 0, 0
        winner_party_id = elems[0]
        unless winner_party_id.blank?
          if party_counts[winner_party_id]
            party_counts[winner_party_id] += 1
          else
            party_counts[winner_party_id] = 1
          end
        end
      end
      seats_key = seats_parliament_key(election)
      party_counts.each_pair do |party_id, seats|
        redis.zadd seats_key, seats, party_id unless party_id.blank?
      end
    end

    def print_top_parties(key)
      elems = redis.zrevrange key, 0, -1, with_scores: true
      elems.each do |elem|
        party_id = elem[0]
        seats = elem[1]
        if !party_id.blank?
          puts "#{::Party.find(party_id).title} seats: #{seats.to_i}"
        else
          puts "No Id seats: #{seats.to_i}"
        end
      end
      puts "Total count of seats #{elems.map { |elem| elem[1] }.reduce(:+)}"
    end

    def update_national_seats_and_votes
      total_time_start = Time.now
      # national level votes
      election = CountryState.current_parliamentary_election
      parties_data = group_by_parties(election)
      votes_key = votes_parliament_key(election)
      insert_into_redis(parties_data, votes_key)
      puts "=========Votes================"
      print_top_parties(votes_key)

      # constituency level votes
      update_national_votes_constituency_level(election)

      update_national_seats(election)
      time_end = Time.now
      seats_key = seats_parliament_key(election)
      puts "=========Seats================"
      print_top_parties(seats_key)
      puts "Total process time #{(time_end - total_time_start).to_f} seconds"
    end
  end
end
