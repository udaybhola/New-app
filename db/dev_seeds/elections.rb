p "creating elections..."

elections = [
  {
    kind: "state",
    country_state: CountryState.find_by(code: 'ka'),
    starts_at: 15.days.from_now,
    ends_at: 21.days.from_now
  },
  {
    kind: "state",
    country_state: CountryState.find_by(code: 'rj'),
    starts_at: 30.days.from_now,
    ends_at: 45.days.from_now
  },
  {
    kind: "state",
    country_state: CountryState.find_by(code: 'gj'),
    starts_at: 10.days.ago,
    ends_at: 5.days.ago
  }
]

elections.each do |election|
  country_state = election[:country_state]
  starts_at = election[:starts_at]
  ends_at = election[:ends_at]
  kind = election[:kind]
  p "creating election for state: #{country_state.code}"
  Election.find_or_create_by(country_state: country_state, kind: kind, starts_at: starts_at, ends_at: ends_at)
end
