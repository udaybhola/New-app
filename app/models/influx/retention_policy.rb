module Influx
  class RetentionPolicy
    include SimulationHelper
    include ActiveModel::Model

    DATA_RESOLUTIONS = %w[
      last_3_hrs
      last_24_hrs
      last_week
      last_month
      since_the_beginning
    ].freeze

    attr_accessor :database

    DATA_RESOLUTIONS.each do |rp|
      define_method "does_#{rp}_exists?" do
        rp_list = database.client.list_retention_policies(database.db_name)
        rp_list.map { |item| item["name"] }.include?(rp)
      end
    end

    def create_all_rps!
      database.client.create_retention_policy(
        DATA_RESOLUTIONS[0],
        database.db_name,
        "3h",
        2,
        false
      )
      database.client.create_retention_policy(
        DATA_RESOLUTIONS[1],
        database.db_name,
        "1d",
        2,
        false
      )
      database.client.create_retention_policy(
        DATA_RESOLUTIONS[2],
        database.db_name,
        "1w",
        2,
        false
      )
      database.client.create_retention_policy(
        DATA_RESOLUTIONS[3],
        database.db_name,
        "4w",
        2,
        false
      )
      database.client.create_retention_policy(
        DATA_RESOLUTIONS[4],
        database.db_name,
        "INF",
        2,
        false
      )
    end

    def destroy_all_rps!
      DATA_RESOLUTIONS.each do |rp|
        database.client.delete_retention_policy(
          rp,
          database.db_name
        )
      end
    end
  end
end
