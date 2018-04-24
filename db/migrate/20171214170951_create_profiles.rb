class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :candidate, type: :uuid
      t.references :religion, type: :uuid
      t.references :caste, type: :uuid
      t.references :education, type: :uuid
      t.references :profession, type: :uuid

      t.string :profile_pic, null: false, default: ''
      t.string :cover_photo, null: false, default: ''

      t.string :name, null: false, default: ''
      t.string :slug, null: false, default: ''
      t.datetime :date_of_birth, default: '1990-01-01 00:00:00'
      t.string :gender, null: false, default: ''

      t.jsonb :contact, default: {}, null: false
      t.jsonb :financials, default: {}, null: false
      t.jsonb :civil_record, default: {}, null: false

      t.timestamps
    end
  end
end
