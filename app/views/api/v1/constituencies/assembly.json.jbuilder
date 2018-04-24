json.cache! ['v1', 'assembly', @cstate] do
  json.data do
    json.extract! @cstate, :id, :name, :code, :is_union_territory
    json.assembly @cstate.assembly_constituencies do |const|
      json.partial! 'constituency', constituency: const, show_geojson: false
    end
  end
  json.status_code 1
end
