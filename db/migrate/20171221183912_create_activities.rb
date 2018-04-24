class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :activable, type: :uuid
      t.string :activable_type, null: false, default: ''
      t.jsonb :meta, null: false, default: {}
      t.jsonb :details, null: false, default: {}
      t.integer :score, null: false, default: 0

      t.timestamps
    end
  end
end

# Activity type & resources type
