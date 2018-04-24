class AddAbbreviationToParty < ActiveRecord::Migration[5.1]
  def change
    add_column :parties, :abbreviation, :string, null: false, default: ""
  end
end
