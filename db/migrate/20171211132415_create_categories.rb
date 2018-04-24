class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.string :slug, null: false, default: ''
      t.string :image, null: false, default: ''
    end
  end
end
