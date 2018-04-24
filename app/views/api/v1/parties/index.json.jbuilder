json.data do
  json.array! @parties, partial: 'party_info', as: :party
end
json.status_code 1
