class AddArchivingToModels < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :archived, :boolean, null: false, default: false
    add_column :candidate_votes, :archived, :boolean, null: false, default: false
    add_column :poll_votes, :archived, :boolean, null: false, default: false
    add_column :comments, :archived, :boolean, null: false, default: false
    add_column :likes, :archived, :boolean, null: false, default: false
    add_column :activities, :archived, :boolean, null: false, default: false
  end

  def down
    remove_column :users, :archived
    remove_column :candidate_votes, :archived
    remove_column :poll_votes, :archived
    remove_column :comments, :archived
    remove_column :likes, :archived
    remove_column :activities, :archived
  end
end
