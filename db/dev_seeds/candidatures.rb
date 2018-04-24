p "creating candidatures..."

candidatures = [
  {
    email: 'neta1@neta.com',
    name: 'neta1',
    phone: '1231231231',
    party: Party.find_by(name: "Bharatiya Janata Party"),
    election: Election.find_by(country_state: CountryState.find_by(code: 'KA'), starts_at: 15.days.from_now, ends_at: 21.days.from_now),
    constituency: CountryState.find_by(code: 'ka').constituencies.first,
    declared: true,
    result: "won"
  },
  {
    email: 'neta2@neta.com',
    name: 'neta2',
    phone: '1231231230',
    party: Party.find_by(name: "Indian National Congress"),
    election: Election.find_by(country_state: CountryState.find_by(code: 'KA'), starts_at: 15.days.from_now, ends_at: 21.days.from_now),
    constituency: CountryState.find_by(code: 'ka').constituencies.first,
    declared: true,
    result: "lost"
  },
  {
    email: 'neta3@neta.com',
    name: 'neta3',
    phone: '1231231232',
    party: Party.find_by(name: "Bharatiya Janata Party"),
    election: Election.find_by(country_state: CountryState.find_by(code: 'KA'), starts_at: 15.days.from_now, ends_at: 21.days.from_now),
    constituency: CountryState.find_by(code: 'ka').constituencies.first,
    declared: false,
    result: "lost"
  },
  {
    email: 'neta2@neta.com',
    name: 'neta2',
    phone: '1231231231',
    party: Party.find_by(name: "Indian National Congress"),
    election: Election.find_by(country_state: CountryState.find_by(code: 'GJ'), starts_at: 10.days.ago, ends_at: 5.days.ago),
    constituency: CountryState.find_by(code: 'gj').constituencies.first,
    declared: true,
    result: "lost"
  }
]

candidatures.each do |candidature|
  p "creating candidature.."
  phone = candidature[:phone]
  party = candidature[:party]
  election = candidature[:election]
  declared = candidature[:declared]
  result = candidature[:result]
  constituency = candidature[:constituency]
  candidate = Candidate.find_by(phone_number: phone)
  Candidature.find_or_create_by(candidate: candidate, party: party, election: election, constituency: constituency, declared: declared, result: result)
end
