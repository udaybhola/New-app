p "creating constituencies "

constituencies = [
  {
    name: "Jaipur North Constituency",
    country_state: CountryState.find_by(abbreviation: 'RJ'),
    kind: "state",
    districts: ["Jaipur"]
  },
  {
    name: "Jaipur Constituency",
    country_state: CountryState.find_by(abbreviation: 'RJ'),
    kind: "national",
    children: ["Jaipur North Constituency"]
  },
  {
    name: "Bengaluru South Constituency",
    country_state: CountryState.find_by(abbreviation: 'KA'),
    kind: "state",
    districts: ["Bengaluru"]
  },
  {
    name: "Bengaluru Constituency",
    country_state: CountryState.find_by(abbreviation: 'KA'),
    kind: "national",
    children: ["Bengaluru South Constituency"],
    districts: ["Bengaluru"]
  }
]

constituencies.each do |constituency|
  name = constituency[:name]
  country_state = constituency[:country_state]
  kind = constituency[:kind]
  children = constituency[:children] || []
  districts = constituency[:districts] || []
  p "creating constituency: #{name}"
  created_constituency = Constituency.find_or_create_by!(name: name, country_state: country_state, kind: kind)
  districts.each do |district|
    created_constituency.districts << District.find_by(name: district)
  end
  children_constituencies = []
  children.each do |child|
    children_constituencies << Constituency.find_by(name: child)
  end
  created_constituency.children = children_constituencies
  created_constituency.save!
end
