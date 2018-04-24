class CreateCandidatures < ActiveRecord::Migration[5.1]
  def change
    create_table :candidatures, id: :uuid do |t|
      t.references :candidate, type: :uuid
      t.references :party, type: :uuid
      t.references :election, type: :uuid
      t.boolean :declared, default: false

      t.string :manifesto, null: false, default: ''
      t.string :result, null: false, default: ''
      t.timestamps
    end
  end
end
