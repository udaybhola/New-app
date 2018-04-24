module Influx
  class EntityInstances
    @@root_database = nil
    @@rp = nil
    @@database = nil
    @@measurements = nil
    @@activities_seeder = nil

    def self.reset
      @@root_database = nil
      @@rp = nil
      @@database = nil
      @@measurements = nil
      @@activities_seeder = nil
    end

    def self.root_db
      unless @@root_database
        db = Influx::Database.new(
          deployment_type: ENV['DEPLOYMENT_TYPE'],
          url: ENV['INFLUXDB_URL'],
          username: ENV['INFLUXDB_USERNAME'],
          password: ENV['INFLUXDB_PASSWORD']
        )
        @@root_database ||= db
      end
      @@root_database
    end

    def self.rp
      unless @@rp
        rp = Influx::RetentionPolicy.new(database: root_db)
        @@rp = rp
      end
      @@rp
    end

    def self.db
      unless @@database
        db = Influx::Database.new(
          deployment_type: ENV['DEPLOYMENT_TYPE'],
          url: "#{ENV['INFLUXDB_URL']}/#{root_db.db_name}",
          username: ENV['INFLUXDB_USERNAME'],
          password: ENV['INFLUXDB_PASSWORD']
        )
        @@database ||= db
      end
      @@database
    end

    def self.candidature_scoring_measurement(rp_name = Influx::RetentionPolicy::DATA_RESOLUTIONS[0])
      raise "Unrecognized retention policy" unless Influx::RetentionPolicy::DATA_RESOLUTIONS.include? rp_name
      @@measurements ||= {}
      @@measurements[:candidature_scoring] = {} unless @@measurements.key? :candidature_scoring

      unless @@measurements[:candidature_scoring][rp_name]
        measurement = Influx::CandidatureScoringMeasurement.new(
          db: db,
          rp_name: rp_name
        )
        @@measurements[:candidature_scoring][rp_name] = measurement
      end
      @@measurements[:candidature_scoring][rp_name]
    end

    def self.influencer_scoring_measurement(rp_name = Influx::RetentionPolicy::DATA_RESOLUTIONS[0])
      raise "Unrecognized retention policy" unless Influx::RetentionPolicy::DATA_RESOLUTIONS.include? rp_name
      @@measurements ||= {}
      @@measurements[:influencer_scoring] = {} unless @@measurements.key? :influencer_scoring

      unless @@measurements[:influencer_scoring][rp_name]
        measurement = Influx::InfluencerScoringMeasurement.new(
          db: db,
          rp_name: rp_name
        )
        @@measurements[:influencer_scoring][rp_name] = measurement
      end
      @@measurements[:influencer_scoring][rp_name]
    end

    def self.post_scoring_measurement(rp_name = Influx::RetentionPolicy::DATA_RESOLUTIONS[0])
      raise "Unrecognized retention policy" unless Influx::RetentionPolicy::DATA_RESOLUTIONS.include? rp_name
      @@measurements ||= {}
      @@measurements[:post_scoring] = {} unless @@measurements.key? :post_scoring

      unless @@measurements[:post_scoring][rp_name]
        measurement = Influx::PostScoringMeasurement.new(
          db: db,
          rp_name: rp_name
        )
        @@measurements[:post_scoring][rp_name] = measurement
      end
      @@measurements[:post_scoring][rp_name]
    end

    def self.poll_vote_scoring_measurement(rp_name = Influx::RetentionPolicy::DATA_RESOLUTIONS[0])
      raise "Unrecognized retention policy" unless Influx::RetentionPolicy::DATA_RESOLUTIONS.include? rp_name
      @@measurements ||= {}
      @@measurements[:poll_vote_scoring] = {} unless @@measurements.key? :poll_vote_scoring

      unless @@measurements[:poll_vote_scoring][rp_name]
        measurement = Influx::PollVoteScoringMeasurement.new(
          db: db,
          rp_name: rp_name
        )
        @@measurements[:poll_vote_scoring][rp_name] = measurement
      end
      @@measurements[:poll_vote_scoring][rp_name]
    end

    def self.seeder_activities
      @@activities_seeder ||= Influx::SeedFromActivities.new
      @@activities_seeder
    end
  end
end
