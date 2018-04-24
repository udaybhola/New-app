class AddFlagStatusToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :status, :string, default: "newly_created"
  end
end
