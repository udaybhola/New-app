json.data do
  json.array! @categories, :id, :name, :slug, :image, :count
end
json.status_code 1
