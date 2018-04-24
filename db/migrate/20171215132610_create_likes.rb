class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :likeable, type: :uuid
      t.string :likeable_type, null: false, default: ''
      t.timestamps
    end

    add_column :posts, :likes_count, :integer, null: false, default: 0
    add_column :posts, :comments_count, :integer, null: false, default: 0
    add_column :poll_options, :poll_votes_count, :integer, null: false, default: 0
  end
end
