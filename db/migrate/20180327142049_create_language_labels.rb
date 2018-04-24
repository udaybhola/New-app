class CreateLanguageLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :language_labels, id: :uuid do |t|
      t.string :key
      t.jsonb :translations

      t.timestamps
    end
    add_index :language_labels, :key, unique: true
  end
end
