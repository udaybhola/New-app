class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :candidature, type: :uuid
      t.string :title, null: false, default: ''
      t.timestamps
    end
  end
end
