class AddGisIndexToMaps < ActiveRecord::Migration[5.1]
  def change
    change_table :maps do |t|
      t.index :shape, using: :gist
    end
  end
end
