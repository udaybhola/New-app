class AddShouldLinkWithPhoneNumberToCandidate < ActiveRecord::Migration[5.1]
  def change
    add_column :candidates, :should_link_with_phone_number, :boolean, default: false
    add_column :candidates, :link_phone_number, :string, :null => false, :default => ""
  end
end
