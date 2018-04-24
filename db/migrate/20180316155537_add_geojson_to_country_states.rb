class AddGeojsonToCountryStates < ActiveRecord::Migration[5.1]
  def change
    add_column :country_states, :assembly_geojson, :jsonb, null: false, default: {}
    add_column :country_states, :parliamentary_geojson, :jsonb, null: false, default: {}
    add_column :country_states, :geo_center, :jsonb, null: false, default: {}
  end
end
