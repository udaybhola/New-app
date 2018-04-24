class CreateCastes < ActiveRecord::Migration[5.1]
  def change
    create_table :castes, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.timestamps
    end
  end
end
