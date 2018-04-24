class AddImagesAsOptionInPoll < ActiveRecord::Migration[5.1]
  def up
    add_column :posts, :poll_options_as_image, :boolean, default: false, null: false
    add_column :poll_options, :image, :string, default: "", null: false
  end

  def down
    remove_column :posts, :poll_options_as_image
    remove_column :poll_options, :image
  end
end