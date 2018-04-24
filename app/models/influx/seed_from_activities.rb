module Influx
  class SeedFromActivities
    def seed
      page_size = 100
      page_num = 0
      total_count = Activity.count
      num_of_iterations = (total_count / page_size) + 1
      Rails.logger.debug "Total #{total_count} activities found"
      puts "Total #{total_count} activities found"
      Rails.logger.debug "Will page #{num_of_iterations} times with size #{page_size}"
      puts "Will page #{num_of_iterations} times with size #{page_size}"
      num_of_iterations.times do
        Rails.logger.debug "Seeding page #{page_num}"
        puts "Seeding page #{page_num}"
        activites = Activity.order('created_at asc').offset(page_num * page_size).limit(page_size)
        activites.each { |activity| seed_activity(activity) }
        page_num += 1
      end
    end

    def seed_activity(activity)
      case activity.activable_type
      when 'User'
        Influx::EntityInstances.influencer_scoring_measurement
                               .ingest_user_created(activity)
      when 'Candidature'
        Influx::EntityInstances.candidature_scoring_measurement
                               .ingest_candidature_created(activity)

      when 'CandidateVote'
        Influx::EntityInstances.candidature_scoring_measurement
                               .ingest_candidature_voted(activity)
        Influx::EntityInstances.influencer_scoring_measurement
                               .ingest_candidature_voted(activity)
      when 'Post'
        Influx::EntityInstances.post_scoring_measurement
                               .ingest_post_created(activity)

      when 'Comment'
        Influx::EntityInstances.post_scoring_measurement
                               .ingest_post_activity(activity)
      when 'Like'
        Influx::EntityInstances.post_scoring_measurement
                               .ingest_post_activity(activity)
      when 'PollVote'
        Influx::EntityInstances.post_scoring_measurement
                               .ingest_post_activity(activity)
        Influx::EntityInstances.poll_vote_scoring_measurement
                               .ingest_poll_voted(activity)
      end
    end
  end
end
