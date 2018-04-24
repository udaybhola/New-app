class CreateParties < ActiveRecord::Migration[5.1]
  def change
    create_table :parties, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.string :image, null: false, default: ''

      t.string :manifesto
      t.jsonb :info, null: false, default: {}
      t.jsonb :contact, null: false, default: {}
      t.timestamps
    end
  end
end
