json.extract! constituency, :name, :id, :total_score
json.parties do
  json.array! constituency.parties, partial: 'top_parties_constituency_wise_constituency_party', as: :party
end
