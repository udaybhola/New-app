class FixElectionCountryIdToUuid < ActiveRecord::Migration[5.1]
  def change
    remove_column :elections, :country_state_id, :bigint
    add_reference :elections, :country_state, type: :uuid
  end
end
