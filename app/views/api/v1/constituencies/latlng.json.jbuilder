json.data do
  json.extract! @cstate, :id, :name, :code, :is_union_territory
  json.parliament @cstate.parliamentary_constituencies do |const|
    json.partial! 'constituency', constituency: const, show_geojson: false
  end
  json.selected do
    json.assembly_id @hit_ac.id
    json.parliamentary_id @hit_ac.parent.id
  end
end
json.status_code 1
