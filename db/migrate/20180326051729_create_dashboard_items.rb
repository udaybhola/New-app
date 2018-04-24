class CreateDashboardItems < ActiveRecord::Migration[5.1]
  def change
    create_table :dashboard_items, id: :uuid do |t|
      t.string :item_type
      t.string :item_sub_type
      t.uuid :item_type_resource_id
      t.string :image
      t.jsonb :data

      t.timestamps
    end

    add_index :dashboard_items, [:item_type, :item_sub_type, :item_type_resource_id], name: 'type_resource_index'
  end
end
