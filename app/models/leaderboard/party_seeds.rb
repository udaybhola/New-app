module Leaderboard
  module PartySeeds
    extend ActiveSupport::Concern
    def drop_current_parliamentary_elections
      time_start = Time.now
      redis.del parliament_key(current_parliament_election)
      current_election = CountryState.current_parliamentary_election
      CountryState.all.each do |cs|
        cs.parliamentary_constituencies.each do |pc|
          key = constituency_parliament_key(cs, pc, current_election)
          redis.del key
        end
      end
      key = parliament_key(CountryState.current_parliamentary_election)
      redis.del key
      time_end = Time.now
      puts "Time to drop is #{(time_end - time_start).to_i} seconds"
    end

    def drop_current_assembly_elections
      time_start = Time.now
      CountryState.all.each do |cs|
        Rails.logger.debug "Start working with state #{cs.name}"
        if cs.current_assembly_election
          key = assembly_key(cs, cs.current_assembly_election)
          current_assembly_election = cs.current_assembly_election
          redis.del key
          cs.assembly_constituencies.each do |ac|
            key = constituency_assembly_key(cs, ac, current_assembly_election)
            redis.del key
          end
          key = assembly_key(cs, cs.current_assembly_election)
          redis.del key
        end
      end
      time_end = Time.now
      puts "Time to drop is #{(time_end - time_start).to_i} seconds"
    end

    def seed_current_parliamentary_elections
      time_start = Time.now
      index = 0
      total = current_parliament_election.candidatures.count
      current_parliament_election.candidatures.each do |candidature|
        Rails.logger.debug "Adding candidature with #{candidature.id}"
        register_candidature_score(candidature)
        index += 1
        puts "Percentage complete #{index.to_f * 100 / total.to_f}"
      end
      time_end = Time.now
      puts "Time to seed is #{(time_end - time_start).to_i} seconds"
    end

    def seed_current_assembly_elections
      total = CountryState.all.count
      index = 0
      time_start = Time.now
      CountryState.all.each do |cs|
        Rails.logger.debug "Start working with state #{cs.name}"
        cs.current_assembly_election&.candidatures&.each do |candidature|
          Rails.logger.debug "Adding candidature with #{candidature.id}"
          register_candidature_score(candidature)
        end
        index += 1
        puts "Percentage complete #{index.to_f * 100 / total.to_f}"
      end
      time_end = Time.now
      puts "Time to seed is #{(time_end - time_start).to_i} seconds"
    end
  end
end
