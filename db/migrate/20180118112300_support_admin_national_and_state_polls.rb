class SupportAdminNationalAndStatePolls < ActiveRecord::Migration[5.1]
  def change
    change_table :posts do |t|
      t.rename :constituency_id, :region_id
      t.string :region_type, null: false, default: ''

      t.boolean :is_admin, null: false, default: false

      t.index :region_type
      t.index :is_admin
    end

    reversible do |change|
      change.up do
        Post.unscoped.update_all(region_type: 'Constituency')
      end
    end
  end
end
