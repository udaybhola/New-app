class AddGeoBoundingCoordsToCountryStates < ActiveRecord::Migration[5.1]
  def change
    add_column :country_states, :geo_bounding_coords, :jsonb
  end
end
