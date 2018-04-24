json.cache! ['v1', 'constituency-geojson', @constituency] do
  json.data do
    json.extract! @constituency, :id, :name
    json.constituency do
      json.partial! 'constituency', constituency: @constituency, show_geojson: true
    end
    json.center do
      json.lng @lon
      json.lat @lat
    end
  end
  json.status_code 1
end
