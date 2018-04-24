class AddCandidaturesData < ActiveRecord::Migration[5.1]
  def change
    add_column :candidatures, :data, :jsonb, null: false, default: {}
  end
end
