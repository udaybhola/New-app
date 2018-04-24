class CreateMobileAppSettings < ActiveRecord::Migration[5.1]
  def up
    create_table :mobile_app_settings, id: :uuid do |t|
      t.string :key, null: false, default: ''
      t.jsonb :value, default: {}, null: false

      t.timestamps
    end
    MobileAppSetting.create key: "CANDIDATURE_DISPLAY_COUNTS", value: {
      voting_booth_mla_candidature_count: 5, voting_booth_mp_candidature_count: 5, dashboard_national_candidature_count: 15, dashboard_state_candidature_count: 15
    }
  end

  def down
    drop_table :mobile_app_settings
  end
end
