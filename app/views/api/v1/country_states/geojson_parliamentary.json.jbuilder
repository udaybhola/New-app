json.cache! ['v1', 'nation-pc-geojson'] do
  json.data do
    json.parliamentary_constituencies do
      json.array! @consts, partial: 'parliamentary_constituency_geojson', as: :const
    end
    json.center do
      # India lat, lon
      json.lng 78.9629
      json.lat 20.5937
    end
  end
  json.status_code 1
end
