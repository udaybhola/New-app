require "influxdb"
# Measurements #
#
# Measurement: Candidate Popularity, fields=score, tags=state_id,constituency_id,candidature_id
# Measurement: Influencer Popularity, fields=score, tags=state_id,constituency_id,influencer_id
# Measurement: Party Popularity, fields=score, tags=state_id,constituency_id,party_id
# Measurement: Candidate Performance, fields=score, tags=state_id,constituency_id,candidate_id,party_id
# Measurement: Issue Performance, fields=score, tags=state_id,constituency_id,issue_id
# Measurement: Poll Performance, fields=score, tags=state_id,constituency_id,poll_id

def setup_env
  @databases = Influx::Config::DATABASES
  @influxdb = Influx::Config::CLIENT
end

def do_create_db
  @databases.each do |database|
    puts "Creating database with name #{database}"
    @influxdb.create_database(database)
  end
  db_list = @influxdb.list_databases
  puts "DB list is \n #{db_list}"
end

def do_drop_db
  @databases.each do |database|
    puts "Dropping database with name #{database}"
    @influxdb.delete_database(database)
  end
  db_list = @influxdb.list_databases
  puts "DB list is \n #{db_list}"
end

namespace :influx do
  desc "Influx management tasks"

  if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
    desc "Setup Influx Old DB"
    task old_setup: [:environment] do
      setup_env
      do_create_db
    end

    task old_create_db: [:environment] do
      setup_env
      do_create_db
    end

    desc "Setup Influx New DB"
    task setup: [:environment] do
      root_db = Influx::EntityInstances.root_db
      root_db.create!
      puts "================================"
      puts "DB Created: #{root_db.exists?}"
      db_list = root_db.client.list_databases
      puts "DB list is \n #{db_list}"
      puts "Creating Retention Policies"
      rp = Influx::EntityInstances.rp
      rp.destroy_all_rps!
      puts "================================"
      puts "3 hrs created: #{rp.does_last_3_hrs_exists?}"
      puts "24 hrs created: #{rp.does_last_24_hrs_exists?}"
      puts "Week created: #{rp.does_last_week_exists?}"
      puts "Month created: #{rp.does_last_month_exists?}"
      puts "Since beginning created: #{rp.does_since_the_beginning_exists?}"
      rp.create_all_rps!
      puts "================================"
      puts "3 hrs created: #{rp.does_last_3_hrs_exists?}"
      puts "24 hrs created: #{rp.does_last_24_hrs_exists?}"
      puts "Week created: #{rp.does_last_week_exists?}"
      puts "Month created: #{rp.does_last_month_exists?}"
      puts "Since beginning created: #{rp.does_since_the_beginning_exists?}"

      puts "================================"

      Influx::EntityInstances.candidature_scoring_measurement
      Influx::EntityInstances.candidature_scoring_measurement.destroy_cqs!
      Influx::EntityInstances.candidature_scoring_measurement.create_cqs!
      puts "Do cqs exists for candidature_scoring_measurement #{Influx::EntityInstances.candidature_scoring_measurement.do_all_cqs_exist?}"
      puts "================================"

      Influx::EntityInstances.influencer_scoring_measurement
      Influx::EntityInstances.influencer_scoring_measurement.destroy_cqs!
      Influx::EntityInstances.influencer_scoring_measurement.create_cqs!
      puts "Do cqs exists for influencer_scoring_measurement #{Influx::EntityInstances.influencer_scoring_measurement.do_all_cqs_exist?}"
      puts "================================"

      Influx::EntityInstances.post_scoring_measurement
      Influx::EntityInstances.post_scoring_measurement.destroy_cqs!
      Influx::EntityInstances.post_scoring_measurement.create_cqs!
      puts "Do cqs exists for post_scoring_measurement #{Influx::EntityInstances.post_scoring_measurement.do_all_cqs_exist?}"
      puts "================================"

      Influx::EntityInstances.poll_vote_scoring_measurement
      Influx::EntityInstances.poll_vote_scoring_measurement.destroy_cqs!
      Influx::EntityInstances.poll_vote_scoring_measurement.create_cqs!
      puts "Do cqs exists for poll_vote_scoring_measurement #{Influx::EntityInstances.poll_vote_scoring_measurement.do_all_cqs_exist?}"
      puts "================================"
    end

    desc "Setup influx data from existing activities table"
    task seed_from_activities_table: [:environment] do
      seeder = Influx::EntityInstances.seeder_activities
      seeder.seed
    end
  end

  # no drestructive operators in prod
  if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
    task old_drop_db: [:environment] do
      setup_env
      do_drop_db
    end

    desc "Drop Influx Old DB"
    task old_destroy: [:environment] do
      setup_env
      do_drop_db
    end

    desc "Destroy influx db"
    task destroy: [:environment] do
      puts "================================"
      root_db = Influx::EntityInstances.root_db
      root_db.destroy!
      Influx::EntityInstances.reset
      puts "DB exists: #{root_db.exists?}"
    end
  end
end
