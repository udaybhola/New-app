class AddCloudinaryResponseToDashboardItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dashboard_items, :cloudinary_response, :jsonb, null: false, default: {}
    remove_column :dashboard_items, :image, :string
  end
end
