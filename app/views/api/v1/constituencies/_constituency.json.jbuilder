json.extract! constituency, :id, :name
if constituency.parent.nil?
  json.assembly constituency.children do |const|
    json.partial! 'constituency', constituency: const, show_geojson: show_geojson
  end
end
json.geojson constituency.map.to_geojson if show_geojson && constituency.map
