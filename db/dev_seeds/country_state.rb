p "creating states.."
states = [
  {
    name: "Telangana",
    abbreviation: "TS"
  },
  {
    name: "Karnataka",
    abbreviation: "KA"
  },
  {
    name: "Rajasthan",
    abbreviation: "RJ"
  },
  {
    name: "Gujrat",
    abbreviation: "GJ"
  }
]

states.each do |state|
  name = state[:name]
  abbreviation = state[:abbreviation]
  p "creating state: #{name}"
  CountryState.find_or_create_by(name: name, abbreviation: abbreviation)
end
