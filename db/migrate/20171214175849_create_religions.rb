class CreateReligions < ActiveRecord::Migration[5.1]
  def change
    create_table :religions, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.timestamps
    end
  end
end
