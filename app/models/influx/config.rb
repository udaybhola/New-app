module Influx
  class Config
    DATABASE_PREFIX = ENV['DEPLOYMENT_TYPE']
    raise "DEPLOYMENT_TYPE env should be set" if DATABASE_PREFIX.blank?
    DATABASES = %w[regular trending hourly daily monthly yearly].map { |name| Influx::Config::DATABASE_PREFIX + "_" + name }
    CLIENT = InfluxDB::Client.new url: ENV['INFLUXDB_URL'], username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']

    NAME_DB_REGULAR = DATABASES[0]
    NAME_DB_TRENDING = DATABASES[1]
    NAME_DB_HOURLY = DATABASES[2]
    NAME_DB_DAILY = DATABASES[3]
    NAME_DB_MONTHLY = DATABASES[4]
    NAME_DB_YEARLY = DATABASES[5]

    DB_REGULAR = InfluxDB::Client.new url: "#{ENV['INFLUXDB_URL']}/#{DATABASES[0]}", username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']
    DB_TRENDING = InfluxDB::Client.new url: "#{ENV['INFLUXDB_URL']}/#{DATABASES[1]}", username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']
    DB_HOURLY = InfluxDB::Client.new url: "#{ENV['INFLUXDB_URL']}/#{DATABASES[2]}", username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']
    DB_DAILY = InfluxDB::Client.new url: "#{ENV['INFLUXDB_URL']}/#{DATABASES[3]}", username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']
    DB_MONTHLY = InfluxDB::Client.new url: "#{ENV['INFLUXDB_URL']}/#{DATABASES[4]}", username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']
    DB_YEARLY = InfluxDB::Client.new url: "#{ENV['INFLUXDB_URL']}/#{DATABASES[5]}", username: ENV['INFLUXDB_USERNAME'], password: ENV['INFLUXDB_PASSWORD']

    MEASUREMENT_CANDIDATURE_POPULARITY = 'candidature_popularity'.freeze
    MEASUREMENT_INFLUENCER_POPULARITY = 'influencer_popularity'.freeze
    MEASUREMENT_POST_TRENDING = 'post_trending'.freeze
    MEASUREMENT_POLL_VOTING_TRENDING = 'poll_voting'.freeze
  end
end
