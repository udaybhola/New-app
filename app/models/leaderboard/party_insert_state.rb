module Leaderboard
  module PartyInsertState
    extend ActiveSupport::Concern

    def update_state_votes_constituency_level(cs, election)
      # Add at individual constituency level
      cs.assembly_constituencies.each do |const|
        parties_data = group_by_parties(election, const)
        votes_key = votes_constituency_assembly_key(const.country_state, const, election)
        insert_into_redis(parties_data, votes_key)
      end
    end

    def update_state_seats(cs, election)
      party_counts = {}
      cs.assembly_constituencies.each do |const|
        votes_key = votes_constituency_assembly_key(const.country_state, const, election)
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
      seats_key = seats_assembly_key(cs, election)
      party_counts.each_pair do |party_id, seats|
        redis.zadd seats_key, seats, party_id unless party_id.blank?
      end
    end

    def update_state_level_seats_and_votes
      time_beginning = Time.now
      CountryState.all.each do |cs|
        puts "=======#{cs.name}========"
        total_time_start = Time.now
        election = cs.current_assembly_election
        if election
          parties_data = group_by_parties(election)
          votes_key = votes_assembly_key(cs, election)
          insert_into_redis(parties_data, votes_key)
          puts "=========Votes================"
          print_top_parties(votes_key)

          update_state_votes_constituency_level(cs, election)
          update_state_seats(cs, election)
          seats_key = seats_assembly_key(cs, election)
          puts "=========Seats================"
          print_top_parties(seats_key)

          time_end = Time.now
          puts "Total process time #{cs.name} #{(time_end - total_time_start).to_f} seconds"
        else
          puts "Skip state #{cs.name} as there is no assembly election"
        end
        puts "================"
      end
      time_last = Time.now
      puts "Total process time #{(time_last - time_beginning).to_f} seconds"
    end
  end
end
