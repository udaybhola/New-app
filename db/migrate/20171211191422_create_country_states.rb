class CreateCountryStates < ActiveRecord::Migration[5.1]
  def change
    create_table :country_states, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.string :slug, null: false, default: ''
      t.string :abbreviation, null: false, default: ''
      t.timestamps
    end
  end
end
