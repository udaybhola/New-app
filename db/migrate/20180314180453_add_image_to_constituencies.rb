class AddImageToConstituencies < ActiveRecord::Migration[5.1]
  def change
    add_column :constituencies, :image, :string
  end
end
