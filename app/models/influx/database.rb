module Influx
  class Database
    include SimulationHelper
    include ActiveModel::Model
    attr_accessor :deployment_type, :url, :username, :password

    def exists?
      database_list = client.list_databases
      database_list.map { |item| item["name"] }.include?(db_name)
    end

    def create!
      if Rails.env.test? || is_in_simulation_mode?
        client.create_database(db_name) unless exists?
      end
    end

    def destroy!
      client.delete_database(db_name) if Rails.env.test? || is_in_simulation_mode?
    end

    def db_name
      if Rails.env.test?
        "neta_test"
      else
        "neta_#{deployment_type}"
      end
    end

    def client
      @client ||= InfluxDB::Client.new url: url, username: username, password: password
      @client
    end
  end
end
