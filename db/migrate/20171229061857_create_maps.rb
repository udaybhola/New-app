class CreateMaps < ActiveRecord::Migration[5.1]
  def change
    create_table :maps, id: :uuid do |t|
      t.references :mappable, type: :uuid
      t.string :mappable_type
      t.string :name
      t.string :kind, null: false, default: ''
      t.string :state_name
      t.string :state_code

      t.multi_polygon :shape, srid: 4326
      t.timestamps
    end
  end
end
