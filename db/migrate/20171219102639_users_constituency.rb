class UsersConstituency < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :constituency, type: :uuid
    add_reference :constituencies, :parent, type: :uuid
  end
end
