class AddPositionToPollOption < ActiveRecord::Migration[5.1]
  def change
    add_column :poll_options, :position, :integer, default: 0
  end
end
