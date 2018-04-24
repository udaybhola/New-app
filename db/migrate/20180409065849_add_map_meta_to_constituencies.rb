class AddMapMetaToConstituencies < ActiveRecord::Migration[5.1]
  def change
    add_column :constituencies, :map_meta, :jsonb
  end
end
