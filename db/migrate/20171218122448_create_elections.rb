class CreateElections < ActiveRecord::Migration[5.1]
  def change
    create_table :elections, id: :uuid do |t|
      t.references :country_state
      t.string :kind, null: false, default: ''

      t.date :starts_at
      t.date :ends_at
      t.timestamps
    end
  end
end
