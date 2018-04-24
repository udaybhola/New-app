class CreateBulkFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :bulk_files, id: :uuid do |t|
      t.references :election, type: :uuid
      t.string :file
      t.string :name
      t.string :status, null: false, default: ''
      t.jsonb :notes, null: false, default: {}
      t.timestamps
    end
  end
end
