districts = [
  {
    "name": "Bengaluru",
    "state": "Karnataka"
  },
  {
    "name": "Ahmedabad",
    "state": "Gujrat"
  },
  {
    "name": "Jaipur",
    "state": "Rajasthan"
  }
]

districts.each do |district|
  name = district[:name]
  state = district[:state]
  p "creating district: #{name}"
  country_state = CountryState.find_by(name: state)
  District.find_or_create_by!(name: name, country_state: country_state)
end
