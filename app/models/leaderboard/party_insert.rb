module Leaderboard
  module PartyInsert
    extend ActiveSupport::Concern
    include Leaderboard::PartyInsertNational
    include Leaderboard::PartyInsertState

    def group_by_parties(election, constituency = nil)
      opts = { election: election }
      opts = { constituency: constituency } if constituency
      party_hash = ::Candidature.where(opts)
                                .joins(:party)
                                .map { |item| { id: item.id, party_id: item.party_id } }
                                .group_by { |item| item[:party_id] }
      parties_data = {}
      party_hash.each_pair do |party_id, cand_arr|
        total_party_votes = Candidature.where(id: cand_arr.map { |i| i[:id] }).map(&:total_votes).reduce(:+)
        parties_data[party_id] = total_party_votes
      end
      parties_data
    end

    def insert_into_redis(parties_data, votes_key)
      parties_data.each_pair do |party_id, total_votes|
        redis.zadd votes_key, total_votes, party_id
      end
    end

    def print_top_parties(key)
      elems = redis.zrevrange key, 0, -1, with_scores: true
      elems.each do |elem|
        party_id = elem[0]
        seats = elem[1]
        if !party_id.blank?
          puts "#{::Party.find(party_id).title}: #{seats.to_i}"
        else
          puts "No Id: #{seats.to_i}"
        end
      end
      puts "Total count #{elems.map { |elem| elem[1] }.reduce(:+)}"
    end

    def image_obj
      !image.file.nil? && image.respond_to?(:full_public_id) ? { cloudinary: { public_id: image.file.public_id } } : nil
    end

    def update_national_and_state_seats_and_votes
      time_start = Time.now
      update_national_seats_and_votes
      DashboardItem.national_statistics.process_stats(true)
      update_state_level_seats_and_votes
      CountryState.all.each do |cs|
        DashboardItem.statistics_of_state(cs).process_stats(true)
      end
      time_end = Time.now
      puts "Total process time #{(time_end - time_start).to_f} seconds"
    end
  end
end
