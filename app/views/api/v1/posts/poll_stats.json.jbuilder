json.data do
  json.poll_id @poll.id
  json.stats do
    json.array! @stats, partial: 'poll_option_stat', as: :poll_option_stat
  end
end
json.status_code 1
