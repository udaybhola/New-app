class CreateLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.string :color, null: false, default: ''

      t.timestamps
    end

    add_reference :candidates, :label, type: :uuid
  end
end
