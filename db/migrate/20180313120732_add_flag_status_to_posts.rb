class AddFlagStatusToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :status, :string, default: "newly_created"
  end
end
