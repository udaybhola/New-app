class CreatePollOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :poll_options, id: :uuid do |t|
      t.references :poll, type: :uuid
      t.string :answer, null: false, default: ''
      t.timestamps
    end
  end
end
