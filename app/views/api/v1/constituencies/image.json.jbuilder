json.cache_if! @constituency.has_image?, ['v1', @constituency.image_cache_key] do
  json.data do
    json.image @image_obj
  end
  json.status_code 1
end
