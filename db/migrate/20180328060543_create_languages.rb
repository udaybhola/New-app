class CreateLanguages < ActiveRecord::Migration[5.1]
  def change
    create_table :languages, id: :uuid do |t|
      t.string :name
      t.string :value
      t.boolean :availability, default: false, null: false
      t.timestamps
    end
    add_index :languages, :name, unique: true
  end
end
