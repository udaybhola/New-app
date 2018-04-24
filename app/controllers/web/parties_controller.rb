class Web::PartiesController < ApplicationController
  def map
    state_id = params.permit(:state_id)[:state_id]
    @state = CountryState.find_by(code: state_id)
    if @state
      setup_state
      renderable = 'state_map'
    else
      setup_nation
      renderable = 'national_map'
    end
    render renderable
  end

  def setup_state
    @zoom_level = zoom_levels(@state.code)
    @state_geojson = @state.generate_assembly_constituencies_geojson
    @lon = @state.geo_center['lon']
    @lat = @state.geo_center['lat']
    @bounding_coords = @state.geo_bounding_coords
    @selected_ids = @state.assembly_constituencies_with_maps.each_with_index.map do |item, _index|
      party_id = Leaderboards.parties.top_party_of_assembly(item)
      party = Party.find(party_id) unless party_id.blank?
      color = party.color if party
      color = "#8c95a7" if color.blank?
      {
        id: item.id,
        color: color
      }
    end
  end

  def setup_nation
    data = CountryState.generate_parliament_constituencies_geojson
    @lon = data[:lon]
    @lat = data[:lat]
    @zoom_level = 4.0
    @national_geojson = data[:geojson]
    @selected_ids = CountryState.parliamentary_constituencies_with_maps.each_with_index.map do |item, _index|
      party_id = Leaderboards.parties.top_party_of_parliament(item)
      party = Party.find(party_id) unless party_id.blank?
      color = party.color if party
      color = "#8c95a7" if color.blank?
      {
        id: item.id,
        color: color
      }
    end
  end

  def zoom_levels(code)
    values = {
      ts: 6.5,
      ka: 6.1,
      pb: 7.2,
      up: 5.9,
      wb: 6.3,
      dl: 10
    }
    values[code.to_sym] || 5.5
  end
end
