class CreateFlags < ActiveRecord::Migration[5.1]
  def change
    create_table :flags, id: :uuid do |t|
      t.string :reason, null: false, default: ''
      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
