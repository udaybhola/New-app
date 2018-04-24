class CreateConstituencies < ActiveRecord::Migration[5.1]
  def change
    create_table :constituencies, id: :uuid do |t|
      t.references :country_state, type: :uuid
      t.string :name, null: false, default: ''
      t.string :slug, null: false, default: ''
      t.string :kind, null: false, default: ''

      t.timestamps
    end
  end
end
