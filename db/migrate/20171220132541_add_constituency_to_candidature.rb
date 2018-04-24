class AddConstituencyToCandidature < ActiveRecord::Migration[5.1]
  def change
    add_reference :candidatures, :constituency, type: :uuid
  end
end
