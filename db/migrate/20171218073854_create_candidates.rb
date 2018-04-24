class CreateCandidates < ActiveRecord::Migration[5.1]
  def change
    create_table :candidates, id: :uuid do |t|
      t.string :phone_number, null: false, default: ''
      t.timestamps
    end
  end
end
