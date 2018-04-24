json.data do
  json.extract! @comment_data, :offset, :limit, :data
end
json.status_code 1
