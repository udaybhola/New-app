json.data do
  json.top_parties_by_votes do
    json.array! @content.top_parties_by_votes, partial: 'api/v1/constituencies/top_party', as: :party
  end

  json.top_parties_by_constituencies do
    json.array! @content.top_parties_by_constituencies, partial: 'top_parties_by_constituencies', as: :party
  end

  json.constituencies do
    json.array! @content.constituencies, partial: 'constituency', as: :constituency
  end
end
json.status_code 1
