class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :constituency, type: :uuid
      t.references :category, type: :uuid

      t.string :type, null: false, default: ''

      t.string :slug, null: false, default: ''

      t.string :title, null: false, default: ''
      t.string :description, null: false, default: ''

      t.string :question, null: false, default: ''

      t.boolean :anonymous, null: false, default: false
      t.timestamps
    end
  end
end
