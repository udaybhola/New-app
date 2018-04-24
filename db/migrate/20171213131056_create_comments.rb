class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :post, type: :uuid
      t.references :parent, type: :uuid

      t.string :text, null: false, default: ''

      t.integer :score, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end
  end
end
