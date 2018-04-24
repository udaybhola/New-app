json.data do
  json.stats do
    json.array! @stats, partial: 'api/v1/constituencies/party_stat', as: :party_stat
  end
end
json.status_code 1
