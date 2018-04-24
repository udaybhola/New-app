class AddFirebaseUrlAndFirebaseLinkResponse < ActiveRecord::Migration[5.1]
  def up
    add_column :candidatures, :firebase_url, :string, default: ""
    add_column :candidatures, :firebase_link_response, :string, default: ""

    add_column :users, :firebase_url, :string, default: ""
    add_column :users, :firebase_link_response, :string, default: ""

    add_column :posts, :firebase_url, :string, default: ""
    add_column :posts, :firebase_link_response, :string, default: ""
  end

  def down
    remove_column :candidatures, :firebase_url, :string
    remove_column :candidatures, :firebase_link_response, :string

    remove_column :users, :firebase_url, :string
    remove_column :users, :firebase_link_response, :string

    remove_column :posts, :firebase_url, :string
    remove_column :posts, :firebase_link_response, :string
  end
end
