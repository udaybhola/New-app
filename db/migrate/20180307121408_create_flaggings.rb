class CreateFlaggings < ActiveRecord::Migration[5.1]
  def change
    create_table :flaggings, id: :uuid do |t|
      t.references :flaggable, type: :uuid, polymorphic: true
      t.references :flag, type: :uuid

      t.timestamps
    end
  end
end
