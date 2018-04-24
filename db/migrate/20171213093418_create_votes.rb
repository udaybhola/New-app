class CreateVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :poll_option, type: :uuid

      t.timestamps
    end
  end
end
