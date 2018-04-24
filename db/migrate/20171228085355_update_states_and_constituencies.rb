class UpdateStatesAndConstituencies < ActiveRecord::Migration[5.1]
  def change
    rename_column :country_states, :abbreviation, :code
    add_column :country_states, :is_union_territory, :boolean, null: false, default: false
  end
end
