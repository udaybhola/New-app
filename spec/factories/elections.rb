FactoryBot.define do
  factory :election do
    country_state
    kind 'assembly'

    starts_at 15.days.from_now
    ends_at 21.days.from_now
  end
end
