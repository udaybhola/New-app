json.extract! const, :id, :name
json.geojson const.map.nil? ? nil : const.map.to_simplified_geojson(0.2)
