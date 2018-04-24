class UsersStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :status, :jsonb, null: false, default: {}
  end
end
