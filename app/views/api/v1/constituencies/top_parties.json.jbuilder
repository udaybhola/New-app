json.data do
  json.array! @parties, partial: 'top_party', as: :party
end
json.status_code 1
