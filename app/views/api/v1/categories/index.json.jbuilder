json.data do
  json.array! @categories, :name, :slug, :image, :id
end
