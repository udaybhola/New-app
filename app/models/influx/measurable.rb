module Influx
  module Measurable
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model
      attr_accessor :db, :rp_name
      attr_reader :name
    end

    def full_name
      "#{db.db_name}.#{rp_name}.#{name}"
    end

    def autogen_db
      %("#{db.db_name}"."autogen"."#{name}")
    end

    def cq_names
      resolutions = Influx::RetentionPolicy::DATA_RESOLUTIONS
      [
        "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[0]}",
        "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[1]}",
        "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[2]}",
        "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[3]}",
        "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[4]}"
      ]
    end

    def do_all_cqs_exist?
      cqs_list = db.client.list_continuous_queries(db.db_name)
      names = cqs_list.map { |cq| cq["name"] }
      (cq_names - names).empty?
    end

    def create_cqs!
      resolutions = Influx::RetentionPolicy::DATA_RESOLUTIONS

      # resolution 0
      cq_name = "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[0]}"
      query = <<-eos
        select sum("score") as "score"
        into "#{db.db_name}"."#{resolutions[0]}"."#{name}"
        from "#{db.db_name}"."autogen"."#{name}"
        group by time(5m), *
      eos

      db.client.create_continuous_query(
        cq_name,
        db.db_name,
        query,
        resample_every: "30m", resample_for: "30m"
      )

      # resolution 1
      cq_name = "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[1]}"
      query = <<-eos
        select sum("score") as "score"
        into "#{db.db_name}"."#{resolutions[1]}"."#{name}"
        from "#{db.db_name}"."autogen"."#{name}"
        group by time(30m), *
      eos

      db.client.create_continuous_query(
        cq_name,
        db.db_name,
        query,
        resample_every: "3h", resample_for: "3h"
      )

      # resolution 2
      cq_name = "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[2]}"
      query = <<-eos
        select sum("score") as "score"
        into "#{db.db_name}"."#{resolutions[2]}"."#{name}"
        from "#{db.db_name}"."autogen"."#{name}"
        group by time(1h), *
      eos

      db.client.create_continuous_query(
        cq_name,
        db.db_name,
        query,
        resample_every: "1d", resample_for: "1d"
      )

      # resolution 3
      cq_name = "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[3]}"
      query = <<-eos
        select sum("score") as "score"
        into "#{db.db_name}"."#{resolutions[3]}"."#{name}"
        from "#{db.db_name}"."autogen"."#{name}"
        group by time(1d), *
      eos

      db.client.create_continuous_query(
        cq_name,
        db.db_name,
        query,
        resample_every: "1w", resample_for: "1w"
      )

      # resolution 4
      cq_name = "#{db.db_name}_#{name}_cq_autogen_into_#{resolutions[4]}"
      query = <<-eos
        select sum("score") as "score"
        into "#{db.db_name}"."#{resolutions[4]}"."#{name}"
        from "#{db.db_name}"."autogen"."#{name}"
        group by time(1w), *
      eos

      db.client.create_continuous_query(
        cq_name,
        db.db_name,
        query,
        resample_every: "4w", resample_for: "4w"
      )
    end

    def destroy_cqs!
      if do_all_cqs_exist?
        cq_names.each do |name|
          db.client.delete_continuous_query(name, db.db_name)
        end
      end
    end
  end
end
