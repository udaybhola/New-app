json.extract! constituency, :id, :name, :kind
json.parent constituency.parent.name unless constituency.parent.nil?
unless constituency.country_state.nil?
  json.country_state do
    json.name constituency.country_state.name
    json.id constituency.country_state.id
  end
end
