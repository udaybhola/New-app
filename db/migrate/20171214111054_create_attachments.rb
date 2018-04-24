class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments, id: :uuid do |t|
      t.references :attachable, type: :uuid
      t.string :attachable_type, null: false, default: ''
      t.string :media, null: false, default: ''
      t.string :caption, null: false, default: ''
      t.timestamps
    end
  end
end
