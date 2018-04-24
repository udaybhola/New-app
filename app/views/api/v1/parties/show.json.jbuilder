json.data do
  json.partial! 'party', party: @party
end
json.status_code 1
