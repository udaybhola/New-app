class CreateDistricts < ActiveRecord::Migration[5.1]
  def change
    create_table :districts, id: :uuid do |t|
      t.references :country_state, type: :uuid
      t.string :name, null: false, default: ''
      t.string :slug, null: false, default: ''
    end
  end
end
