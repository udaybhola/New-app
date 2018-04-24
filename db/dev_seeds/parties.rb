p "creating parties..."

parties = [
  {
    name: "Bharatiya Janata Party"
  },
  {
    name: "Indian National Congress"
  },
  {
    name: "Telangana Rashtra Samithi"
  },
  {
    name: "Shiromani Akali Dal"
  }
]

parties.each do |party|
  p "creating party: #{party}"
  name = party[:name]
  Party.find_or_create_by(name: name)
end
