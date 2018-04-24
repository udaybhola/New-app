class AddColorToParty < ActiveRecord::Migration[5.1]
  def change
    add_column :parties, :color, :string, null: false, default: ""
  end
end
