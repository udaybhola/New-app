json.data do
  json.array! @languages do |language|
    json.extract! language, :id, :name, :value
  end
end
json.status_code 1
