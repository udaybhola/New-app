class MobileAppSetting < ApplicationRecord
  validates :key, presence: true
  store_accessor :value,
                 :dashboard_state_candidature_count,
                 :voting_booth_mla_candidature_count,
                 :voting_booth_mp_candidature_count,
                 :dashboard_national_candidature_count
end
