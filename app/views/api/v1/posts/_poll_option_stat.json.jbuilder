json.extract! poll_option_stat, :poll_option_id
json.values do
  json.array! poll_option_stat.values, partial: 'poll_option_stat_value', as: :poll_option_stat_value
end
