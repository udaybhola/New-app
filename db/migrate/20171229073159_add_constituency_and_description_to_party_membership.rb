class AddConstituencyAndDescriptionToPartyMembership < ActiveRecord::Migration[5.1]
  def change
    add_reference :party_memberships, :constituency, type: :uuid
    add_column :party_memberships, :description, :string
  end
end
