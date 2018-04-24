json.data do
  json.array! @candidatures, :id, :year, :constituency, :election, :party, :result, :party_abbreviation
end
json.status_code 1
