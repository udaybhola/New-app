class AddIndicesToPolymorphicAssociations < ActiveRecord::Migration[5.1]
  def change
    add_index :activities, [:activable_type, :activable_id]
    add_index :likes, [:likeable_type, :likeable_id]
    add_index :maps, [:mappable_type, :mappable_id]
    add_index :posts, [:region_type, :region_id]
    add_index :attachments, [:attachable_type, :attachable_id]
  end
end
