json.cache! ['v1', 'parliament-geojson', @cstate] do
  json.data do
    json.extract! @cstate, :id, :name, :code, :is_union_territory
    json.parliament @cstate.parliamentary_constituencies do |const|
      json.partial! 'constituency', constituency: const, show_geojson: true
    end
    json.center do
      json.lon @lon
      json.lat @lat
    end
  end
  json.status_code 1
end
