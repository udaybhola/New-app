json.cache! ['v1', 'cs-geojson', @cstate] do
  json.data do
    json.extract! @cstate, :id, :name, :code, :is_union_territory
    json.geojson @cstate.map.to_geojson
    json.center do
      json.lng @lon
      json.lat @lat
    end
  end
  json.status_code 1
end
