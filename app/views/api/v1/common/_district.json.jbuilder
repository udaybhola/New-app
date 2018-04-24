json.extract! district, :id, :name
json.country_state do
  json.name district.country_state.name
  json.id district.country_state.id
end
