json.extract! party_stat, :party_id
json.values do
  json.array! party_stat.values, partial: 'api/v1/constituencies/party_stat_value', as: :party_stat_value
end
