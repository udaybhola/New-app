json.data do
  json.array! @content, partial: 'top_parties_constituency_wise_constituency', as: :constituency
end
json.status_code 1
