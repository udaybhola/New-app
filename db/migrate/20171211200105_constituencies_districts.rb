class ConstituenciesDistricts < ActiveRecord::Migration[5.1]
  def change
    create_table :constituencies_districts, id: false do |t|
      t.references :constituency, type: :uuid
      t.references :district, type: :uuid
    end
  end
end
