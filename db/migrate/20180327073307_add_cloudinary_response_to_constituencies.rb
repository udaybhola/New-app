class AddCloudinaryResponseToConstituencies < ActiveRecord::Migration[5.1]
  def change
    add_column :constituencies, :cloudinary_response, :jsonb, null: false, default: {}
    remove_column :constituencies, :image, :string
  end
end
