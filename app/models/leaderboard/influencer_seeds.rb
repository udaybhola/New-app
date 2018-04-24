module Leaderboard
  module InfluencerSeeds
    extend ActiveSupport::Concern
    def drop_all
      time_start = Time.now
      redis.del national_key
      CountryState.all.each do |cs|
        key = state_key(cs)
        redis.del key
        cs.assembly_constituencies.each do |const|
          key = constituency_key(cs, const)
          redis.del key
        end
      end
      time_end = Time.now
      puts "Time to drop is #{(time_end - time_start).to_i} seconds"
    end

    def seed_all
      time_start = Time.now
      index = 0
      total = User.all.count
      User.all.each do |user|
        Rails.logger.debug "Adding user with #{user.id}"
        register_influencer_score(user) if user.constituency
        index += 1
        puts "Percentage complete #{index.to_f * 100 / total.to_f}"
      end
      time_end = Time.now
      puts "Time to seed is #{(time_end - time_start).to_i} seconds"
    end
  end
end
