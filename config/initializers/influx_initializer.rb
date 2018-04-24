# warm up all influx instances
unless Rails.env.test?
  Influx::EntityInstances.root_db
  Influx::EntityInstances.rp
  Influx::EntityInstances.db
  Influx::EntityInstances.candidature_scoring_measurement
  Influx::EntityInstances.influencer_scoring_measurement
  Influx::EntityInstances.post_scoring_measurement
  Influx::EntityInstances.poll_vote_scoring_measurement
  Influx::EntityInstances.seeder_activities
end
