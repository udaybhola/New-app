class ShowPollOnDashboard < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :show_on_dashboard, :boolean, null: false, default: false
    add_column :posts, :archived, :boolean, null: false, default: false

    add_column :posts, :position, :integer, null: false, default: 0
  end
end
