module Influx
  class PollVoteScoringMeasurement
    include Influx::Measurable

    def name
      'measurement_poll_vote_scoring'
    end

    def tags
      %w[score poll_id poll_option_id user_id]
    end

    def all_tags_query_string
      tags.map { |i| %("#{i}") }.join(", ")
    end

    def polling_results(poll_id)
      return [] if poll_id.blank?

      query = <<-eos
      select sum("score") as "score" from #{autogen_db}
        where time >= now() - 520w and time <= now()
        and "poll_id" = '#{poll_id}'
        group by "poll_id", "poll_option_id"
      eos
      data = db.client.query query
    end

    def poll_stats(options = {})
      valid_resolutions = %w[last_24_hours last_week last_month since_the_beginning]

      poll_id = options[:poll_id]
      resolution = options[:resolution]
      return [] if poll_id.blank?
      time_start = "'2018-01-01T00:00:00Z'"
      time_end = "now()"
      group_by = "1w"

      case resolution
      when "last_24_hours"
        time_start = "now() - 24h"
        epoch = Time.at(0)
        now = Time.now
        minute_span = 60
        total_minutes = ((now - epoch) / minute_span).to_i
        grouping = 60
        offset = (total_minutes % grouping) - grouping
        group_by = "#{grouping}m, #{offset}m"

      when "last_week"
        time_start = "now() - 1w"

        epoch = Time.at(0)
        now = Time.now
        hour_span = 60 * 60
        total_hours = ((now - epoch) / hour_span).to_i
        grouping = 24
        offset = (total_hours % grouping) - grouping
        group_by = "#{grouping}h, #{offset}h"

      when "last_month"
        time_start = "now() - 5w"

        epoch = Time.at(0)
        now = Time.now
        day_span = 24 * 60 * 60
        total_days = ((now - epoch) / day_span).to_i
        grouping = 7
        offset = (total_days % grouping) - grouping
        group_by = "#{grouping}d, #{offset}d"

      when "since_the_beginning"
        epoch = Time.at(0)
        now = Time.now
        day_span = 24 * 60 * 60
        total_days = ((now - epoch) / day_span).to_i
        grouping = 30
        offset = (total_days % grouping) - grouping
        group_by = "#{grouping}d, #{offset}d"
      else
        return []
      end

      query = <<-eos
      select cumulative_sum(sum("score")) as "score" from #{autogen_db}
        where time >= #{time_start} and time <= #{time_end}
        and "poll_id" = '#{poll_id}'
        group by "poll_id", "poll_option_id", time(#{group_by}) fill(0)
      eos
      data = db.client.query query
      window_count = 0
      result = data.map do |point|
        item = ApiResponseModels::CustomOstruct.new
        item.poll_option_id = point["tags"]["poll_option_id"]
        item.values = point["values"].map do |score_point|
          sp = ApiResponseModels::CustomOstruct.new
          sp.time = score_point["time"]
          sp.score = score_point["score"]
          sp
        end
        window_count = item.values.count > window_count ? item.values.count : window_count
        item
      end
      totals = []
      window_count.times do |index|
        totals << result.map { |item| item.values[index].score }.reduce(&:+)
      end
      result.each do |item|
        item.values.each_with_index do |value, index|
          value.percentage = totals[index] == 0 ? 0 : value.score.to_f * 100.to_f / totals[index].to_f
        end
      end
      result
    end

    def ingest_poll_voted(activity)
      poll_vote = activity.activable
      previous_votes = poll_vote.previous_votes
      if previous_votes.empty?
        data = {
          values:    { score: 1 },
          tags:      { poll_id: poll_vote.poll_id,
                       poll_option_id: poll_vote.poll_option_id,
                       user_id: poll_vote.user ? poll_vote.user.id : 'none' },
          timestamp: poll_vote.created_at.to_i
        }
        db.client.write_point(name, data)
      else
        prev_vote = poll_vote.previous_votes.first
        data_one = {
          series: name,
          values:    { score: 1 },
          tags:      { poll_id: poll_vote.poll_id,
                       poll_option_id: poll_vote.poll_option_id,
                       user_id: prev_vote.user ? poll_vote.user.id : 'none' },
          timestamp: poll_vote.created_at.to_i
        }
        data_two = {
          series: name,
          values:    { score: -1 },
          tags:      { poll_id: prev_vote.poll_id,
                       poll_option_id: prev_vote.poll_option_id,
                       user_id: prev_vote.user ? prev_vote.user.id : 'none' },
          timestamp: poll_vote.created_at.to_i
        }
        content = []
        content << data_one
        content << data_two
        db.client.write_points(content, 's')
      end
    end
  end
end
